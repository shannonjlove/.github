# Higgsfield Ecosystem (Cursor plugin)

Local Cursor plugin that wires Shannon's Higgsfield GitHub repos into skills, slash commands, and the Higgsfield MCP connector.

## What gets installed

- **Prompt skill** from [higgsfield-ai-prompt-skill](https://github.com/shannonjlove/higgsfield-ai-prompt-skill)
- **19 UGC / Seedance skills** from [higgsfield-claude-skills](https://github.com/shannonjlove/higgsfield-claude-skills)
- **Higgsfield MCP** at `https://mcp.higgsfield.ai/mcp`
- Companion tools (installed by `scripts/install-higgsfield-ecosystem.sh`):
  - Higgsfield AI CLI (`higgsfield`)
  - Python SDK (`higgsfield-client`)
  - Legacy training package in an isolated venv
  - Open Higgsfield / Clabstream AI Studio npm dependencies

## Install

From the repository root:

```bash
git submodule update --init --recursive
bash scripts/install-higgsfield-ecosystem.sh
```

Cursor loads local plugins from `~/.cursor/plugins/local/higgsfield-ecosystem/`. Reload the window after install (`Developer: Reload Window`).

## Connect (auth)

1. In Cursor desktop: **Settings → Tools & MCP → Connect** next to **Higgsfield**.
2. Or run `higgsfield auth login` for the CLI.
3. For the Python SDK, set `HF_KEY` or `HF_API_KEY` + `HF_API_SECRET` from [Higgsfield Cloud](https://cloud.higgsfield.ai/).

Cloud Agents cannot complete the Higgsfield OAuth handshake. Authenticate once on desktop, then MCP tools become available in that client.

## Usage

```
/higgsfield-prompt   write a cinematic Kling / Seedance prompt
/01-cinematic        Seedance cinematic style pack
/ugc-video-auto      image → Seedance UGC pipeline (needs Playwright MCP)
/higgs               run a generation through Higgsfield MCP
```

Studio UI (optional):

```bash
cd vendor/Open-Higgsfield-AI
npm run dev
```

Then open `http://localhost:3000`.
