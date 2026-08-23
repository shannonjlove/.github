#!/usr/bin/env bash
# Connect and install https://github.com/lovecloudsjl/.github.git
# Idempotent: safe to re-run after source checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="${ROOT}/vendor/lovecloudsjl-github"
REMOTE="https://github.com/lovecloudsjl/.github.git"

log() {
  printf '[lovecloudsjl-github] %s\n' "$*"
}

has_snapshot() {
  [[ -f "${DEST}/README.md" && -f "${DEST}/profile/README.md" ]]
}

if [[ -f "${ROOT}/.gitmodules" ]]; then
  git -C "${ROOT}" submodule update --init --recursive || true
fi

if [[ -e "${DEST}/.git" ]] && git -C "${DEST}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "present ${DEST} (git checkout)"
elif git clone --quiet "${REMOTE}" "${DEST}.clone"; then
  rm -rf "${DEST}"
  mv "${DEST}.clone" "${DEST}"
  log "cloned ${REMOTE} -> ${DEST}"
else
  rm -rf "${DEST}.clone"
  if has_snapshot; then
    log "WARN: could not clone ${REMOTE} (missing, private, or no credentials)"
    log "keeping API snapshot at ${DEST} (see SOURCE.md)"
  else
    log "ERROR: ${REMOTE} is not cloneable and no snapshot is present"
    exit 1
  fi
fi

if ! has_snapshot; then
  log "ERROR: expected README.md and profile/README.md under ${DEST}"
  exit 1
fi

log "connected ${DEST}"
log "root README: ${DEST}/README.md"
log "profile README: ${DEST}/profile/README.md"
log "done"
ls -1 "${DEST}"
