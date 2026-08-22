#!/usr/bin/env bash
# Install and connect the vendored Higgsfield repos: Cursor plugin, CLI,
# Python client, isolated training venv, and Open Higgsfield studio deps.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_SRC="$ROOT/plugins/higgsfield-ecosystem"
PLUGIN_DST="${HIGGSFIELD_PLUGIN_HOME:-$HOME/.cursor/plugins/local/higgsfield-ecosystem}"
TRAIN_VENV="${HIGGSFIELD_TRAIN_VENV:-$HOME/.local/share/higgsfield-training}"
export PATH="$HOME/.local/bin:$PATH"

log() { printf '==> %s\n' "$*"; }

require_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "Missing $path — run: git submodule update --init --recursive" >&2
    exit 1
  fi
}

require_dir "$ROOT/vendor/higgsfield-claude-skills"
require_dir "$ROOT/vendor/higgsfield-ai-prompt-skill"
require_dir "$ROOT/vendor/higgsfield-cli"
require_dir "$ROOT/vendor/higgsfield-client"
require_dir "$ROOT/vendor/higgsfield"
require_dir "$ROOT/vendor/Open-Higgsfield-AI"

install_cli() {
  mkdir -p "$HOME/.local/bin"
  if command -v higgsfield >/dev/null 2>&1 && higgsfield version >/dev/null 2>&1; then
    log "CLI already installed: $(higgsfield version 2>/dev/null | head -n 1)"
    return 0
  fi
  log "Installing Higgsfield AI CLI into $HOME/.local"
  if curl -fsSL https://raw.githubusercontent.com/higgsfield-ai/cli/main/install.sh | sh -s -- --prefix="$HOME/.local" --no-hf; then
    return 0
  fi
  log "Release installer failed; falling back to npm prefix install"
  npm install -g --prefix "$HOME/.local" @higgsfield/cli
}

install_python() {
  local sdk_venv="${HIGGSFIELD_SDK_VENV:-$HOME/.local/share/higgsfield-sdk}"
  local py_ver
  py_ver="$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')"
  local user_site
  user_site="$(python3 -m site --user-site)"

  log "Installing higgsfield-client into $sdk_venv"
  if [[ -d "$sdk_venv" && ! -x "$sdk_venv/bin/python" ]]; then
    rm -rf "$sdk_venv"
  fi
  python3 -m venv "$sdk_venv"
  "$sdk_venv/bin/pip" install --upgrade pip >/dev/null
  "$sdk_venv/bin/pip" install -e "$ROOT/vendor/higgsfield-client"
  mkdir -p "$user_site" "$HOME/.local/bin"
  echo "$sdk_venv/lib/$py_ver/site-packages" > "$user_site/higgsfield-sdk.pth"
  cat > "$HOME/.local/bin/higgsfield-python" <<EOF
#!/usr/bin/env bash
exec "$sdk_venv/bin/python" "\$@"
EOF
  chmod +x "$HOME/.local/bin/higgsfield-python"

  log "Installing legacy higgsfield training package into $TRAIN_VENV"
  if [[ -d "$TRAIN_VENV" && ! -x "$TRAIN_VENV/bin/python" ]]; then
    rm -rf "$TRAIN_VENV"
  fi
  python3 -m venv "$TRAIN_VENV"
  # Isolated so its `higgsfield` console script cannot shadow the AI CLI.
  "$TRAIN_VENV/bin/pip" install --upgrade pip >/dev/null
  "$TRAIN_VENV/bin/pip" install -e "$ROOT/vendor/higgsfield"
  mkdir -p "$HOME/.local/bin"
  cat > "$HOME/.local/bin/higgsfield-train" <<EOF
#!/usr/bin/env bash
exec "$TRAIN_VENV/bin/higgsfield" "\$@"
EOF
  chmod +x "$HOME/.local/bin/higgsfield-train"
}

install_studio() {
  log "Installing Open Higgsfield / Clabstream AI Studio dependencies"
  (
    cd "$ROOT/vendor/Open-Higgsfield-AI"
    if [[ -f package-lock.json ]]; then
      npm ci
    else
      npm install
    fi
  )
}

copy_skill_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  # Keep skill files; drop VCS and local junk so the plugin stays a real copy.
  tar -C "$src" --exclude='.git' --exclude='node_modules' --exclude='.venv' \
    --exclude='__pycache__' --exclude='workspace/input' --exclude='workspace/output' \
    --exclude='workspace/processed' -cf - . | tar -C "$dest" -xf -
}

assemble_plugin() {
  log "Assembling Cursor plugin at $PLUGIN_DST"
  mkdir -p "$PLUGIN_DST"
  rm -rf "$PLUGIN_DST/skills" "$PLUGIN_DST/commands" "$PLUGIN_DST/rules" "$PLUGIN_DST/.cursor-plugin"
  mkdir -p "$PLUGIN_DST/skills" "$PLUGIN_DST/commands" "$PLUGIN_DST/rules" "$PLUGIN_DST/.cursor-plugin"

  cp "$PLUGIN_SRC/.cursor-plugin/plugin.json" "$PLUGIN_DST/.cursor-plugin/plugin.json"
  cp "$PLUGIN_SRC/mcp.json" "$PLUGIN_DST/mcp.json"
  cp "$PLUGIN_SRC/README.md" "$PLUGIN_DST/README.md"
  cp "$PLUGIN_SRC/rules/"*.mdc "$PLUGIN_DST/rules/"

  # Prompt library as one dispatcher skill (preserves relative paths).
  copy_skill_tree "$ROOT/vendor/higgsfield-ai-prompt-skill" "$PLUGIN_DST/skills/higgsfield"

  # Nested prompt sub-skills as first-class Cursor skills.
  local sub
  for sub in "$ROOT/vendor/higgsfield-ai-prompt-skill/skills"/*; do
    [[ -d "$sub" && -f "$sub/SKILL.md" ]] || continue
    copy_skill_tree "$sub" "$PLUGIN_DST/skills/$(basename "$sub")"
  done

  # Claude/Seedance/UGC skill pack.
  for sub in "$ROOT/vendor/higgsfield-claude-skills"/*; do
    [[ -d "$sub" && -f "$sub/SKILL.md" ]] || continue
    copy_skill_tree "$sub" "$PLUGIN_DST/skills/$(basename "$sub")"
  done

  python3 - "$PLUGIN_DST" "$PLUGIN_SRC" <<'PY'
from pathlib import Path
import json
import re
import shutil
import sys

plugin = Path(sys.argv[1])
plugin_src = Path(sys.argv[2])
commands = plugin / "commands"
commands.mkdir(parents=True, exist_ok=True)

def frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---"):
        return {}
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}
    data: dict[str, str] = {}
    key = None
    chunks: list[str] = []
    for raw in parts[1].splitlines():
        line = raw.rstrip()
        if not line.strip():
            continue
        if key and (line.startswith("  ") or line.startswith("\t") or line.startswith(">")):
            chunks.append(line.strip())
            continue
        if key:
            data[key] = " ".join(chunks).strip()
            key, chunks = None, []
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not match:
            continue
        key = match.group(1)
        rest = match.group(2).strip()
        if rest == ">" or rest == "|":
            chunks = []
        else:
            chunks = [rest]
    if key:
        data[key] = " ".join(chunks).strip()
    return data

written: set[str] = set()
for skill_md in sorted((plugin / "skills").glob("*/SKILL.md")):
    meta = frontmatter(skill_md.read_text(encoding="utf-8", errors="replace"))
    name = meta.get("name") or skill_md.parent.name
    slug = re.sub(r"[^a-z0-9-]+", "-", name.lower()).strip("-")
    if not slug or slug in written:
        continue
    desc = meta.get("description") or f"Run the {name} Higgsfield skill."
    desc = re.sub(r"\s+", " ", desc).strip()
    body = (
        f"---\nname: {json.dumps(name, ensure_ascii=False)}\n"
        f"description: {json.dumps(desc, ensure_ascii=False)}\n---\n\n"
        f"# /{slug}\n\n"
        f"Use the `{name}` skill from this plugin (`skills/{skill_md.parent.name}/SKILL.md`).\n"
        f"Write or refine the Higgsfield prompt with that skill, then execute via Higgsfield MCP or `higgsfield generate create`.\n"
    )
    (commands / f"{slug}.md").write_text(body, encoding="utf-8")
    written.add(slug)

# Natural-language generate entrypoint (MCP).
(commands / "higgs.md").write_text(
    """---
name: higgs
description: Run Higgsfield workflows in natural language — generate images and videos, predict virality, manage media, check your account.
---

# /higgs

Natural-language entrypoint for Higgsfield. Routes to the right MCP tool after a prompt skill has prepared the request.

## Examples

```
/higgs Make a cinematic poster of a samurai in neon Tokyo, 16:9
/higgs Animate this product shot — slow push-in, 5s, 9:16
/higgs How many credits do I have left?
```

Use `generate_image` / `generate_video` on the Higgsfield MCP. Upload local files with `media_upload` + `media_confirm` first.
""",
    encoding="utf-8",
)
print(f"wrote {len(written) + 1} commands")
src_commands = plugin_src / "commands"
if src_commands.exists():
    shutil.rmtree(src_commands)
shutil.copytree(commands, src_commands)
PY
}

install_cli
install_python
install_studio
assemble_plugin

log "Verifying"
python3 - <<'PY'
import higgsfield_client
print("higgsfield_client import: ok", getattr(higgsfield_client, "__file__", ""))
PY
higgsfield version || true
"$TRAIN_VENV/bin/python" -c "import higgsfield; print('training package import: ok')"
test -f "$PLUGIN_DST/.cursor-plugin/plugin.json"
test -f "$PLUGIN_DST/skills/higgsfield/SKILL.md"
test -f "$PLUGIN_DST/mcp.json"
log "Plugin skills: $(find "$PLUGIN_DST/skills" -mindepth 1 -maxdepth 1 -type d | wc -l)"
log "Done. Reload Cursor, then connect Higgsfield under Settings → Tools & MCP."
