#!/usr/bin/env bash
# Connect and install the Tag libraries listed for this workspace.
# Idempotent: safe to re-run after source checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBS="${ROOT}/libs"
GOBIN="${GOBIN:-${HOME}/go/bin}"
VIM_PACK="${HOME}/.vim/pack/tag-libraries/start"

mkdir -p "${LIBS}" "${GOBIN}" "${VIM_PACK}"
export PATH="${GOBIN}:${PATH}"

log() {
  printf '[tag-libs] %s\n' "$*"
}

clone_or_update() {
  local url="$1"
  local dest="$2"
  if git -C "${dest}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "present ${dest}"
    return 0
  fi
  if git clone --quiet "${url}" "${dest}"; then
    log "cloned ${url} -> ${dest}"
    return 0
  fi
  log "WARN: could not clone ${url} (missing, private, or no credentials)"
  return 1
}

if [[ -f "${ROOT}/.gitmodules" ]]; then
  git -C "${ROOT}" submodule update --init --recursive
  log "initialized git submodules under libs/"
fi

# Public / already-submoduled libraries
clone_or_update "https://github.com/shannonjlove/TagListView.git" "${LIBS}/TagListView" || true
clone_or_update "https://github.com/titoBouzout/Tag.git" "${LIBS}/sublime-Tag" || true
clone_or_update "https://github.com/shannonjlove/tagbar.git" "${LIBS}/tagbar" || true
clone_or_update "https://github.com/shannonjlove/TagStudio.git" "${LIBS}/TagStudio" || true
clone_or_update "https://github.com/shannonjlove/tag2.git" "${LIBS}/tag2" || true
# Requested as git@github.com / https://github.com/lovecloudsjl/tag.git.
# That remote is not cloneable with the Cloud Agent git identity; fall back to the
# public upstream of the same MIT-licensed macOS `tag` CLI.
if ! clone_or_update "https://github.com/lovecloudsjl/tag.git" "${LIBS}/macos-tag"; then
  clone_or_update "https://github.com/jdberry/tag.git" "${LIBS}/macos-tag" || true
fi

# tag2 — Go audio metadata library (github.com/dhowden/tag fork)
if [[ -f "${LIBS}/tag2/go.mod" ]]; then
  (
    cd "${LIBS}/tag2"
    go mod download
    go test ./...
    go install ./cmd/tag ./cmd/sum ./cmd/check
  )
  log "installed tag2 CLI tools into ${GOBIN} (tag, sum, check)"
else
  log "WARN: tag2 sources missing; skipped Go install"
fi

# tagbar — Vim class outline plugin
if [[ -d "${LIBS}/tagbar/plugin" ]]; then
  ln -sfn "${LIBS}/tagbar" "${VIM_PACK}/tagbar"
  if command -v vim >/dev/null 2>&1; then
    vim -es -u NONE -c "helptags ${VIM_PACK}/tagbar/doc" -c qa! >/dev/null 2>&1 || true
  fi
  log "linked tagbar into ${VIM_PACK}/tagbar"
else
  log "WARN: tagbar sources missing; skipped Vim pack install"
fi

# TagStudio — requires Python 3.14 (see libs/TagStudio/pyproject.toml)
if [[ -f "${LIBS}/TagStudio/pyproject.toml" ]]; then
  if command -v python3.14 >/dev/null 2>&1; then
    python3.14 -m venv "${LIBS}/TagStudio/.venv"
    # shellcheck disable=SC1091
    source "${LIBS}/TagStudio/.venv/bin/activate"
    python -m pip install --upgrade pip
    python -m pip install -e "${LIBS}/TagStudio"
    deactivate
    log "installed TagStudio into libs/TagStudio/.venv"
  else
    log "TagStudio connected at ${LIBS}/TagStudio (Python 3.14 not present; skipped pip install)"
  fi
fi

# TagListView is an iOS Swift package; macos-tag is an Objective-C macOS CLI.
# Neither can be built on Linux without Apple SDKs. Sources are connected only.
if [[ -f "${LIBS}/TagListView/Package.swift" ]]; then
  log "TagListView connected (iOS Swift package; no Linux build)"
fi
if [[ -f "${LIBS}/macos-tag/Makefile" ]]; then
  log "macos-tag connected (needs macOS Foundation/CoreServices to build)"
elif [[ ! -d "${LIBS}/macos-tag" ]]; then
  log "macos-tag not present — clone https://github.com/lovecloudsjl/tag.git with an account that can read it"
fi

if [[ -d "${LIBS}/sublime-Tag" ]]; then
  log "sublime-Tag connected (Sublime Text plugin; copy to Packages/Tag to use in the editor)"
fi

log "done"
ls -1 "${LIBS}"
