#!/usr/bin/env bash
# Connect and install https://github.com/shannonjlove/go-koofrclient.git
# and https://github.com/shannonjlove/python-koofr.git
# Idempotent: safe to re-run after source checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR="${ROOT}/vendor"
GO_DEST="${VENDOR}/go-koofrclient"
PY_DEST="${VENDOR}/python-koofr"
GOPATH="${GOPATH:-${HOME}/go}"
PY_VENV="${PY_DEST}/.venv"

export GOPATH
export PATH="${GOPATH}/bin:${PATH}"

log() {
  printf '[koofr-clients] %s\n' "$*"
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
  log "initialized git submodules under vendor/"
fi

clone_or_update "https://github.com/shannonjlove/go-koofrclient.git" "${GO_DEST}" || true
clone_or_update "https://github.com/shannonjlove/python-koofr.git" "${PY_DEST}" || true

# go-koofrclient — GOPATH-era library (no go.mod). Canonical import is
# github.com/koofr/go-koofrclient; Shannon's fork is linked at both paths.
# Go 1.18+ removed `go get` in GOPATH mode, so clone go-httpclient and `go build`.
if [[ -f "${GO_DEST}/client.go" ]]; then
  mkdir -p "${GOPATH}/src/github.com/koofr" "${GOPATH}/src/github.com/shannonjlove"
  ln -sfn "${GO_DEST}" "${GOPATH}/src/github.com/koofr/go-koofrclient"
  ln -sfn "${GO_DEST}" "${GOPATH}/src/github.com/shannonjlove/go-koofrclient"
  HTTPCLIENT_DEST="${GOPATH}/src/github.com/koofr/go-httpclient"
  if [[ ! -f "${HTTPCLIENT_DEST}/httpclient.go" ]]; then
    git clone --quiet https://github.com/koofr/go-httpclient.git "${HTTPCLIENT_DEST}"
    log "cloned github.com/koofr/go-httpclient -> ${HTTPCLIENT_DEST}"
  else
    log "present ${HTTPCLIENT_DEST}"
  fi
  GO111MODULE=off go build -o /dev/null github.com/koofr/go-koofrclient
  GO111MODULE=off go list github.com/koofr/go-koofrclient
  log "installed go-koofrclient into GOPATH (${GOPATH})"
  log "import: github.com/koofr/go-koofrclient (also github.com/shannonjlove/go-koofrclient)"
else
  log "WARN: go-koofrclient sources missing; skipped Go install"
fi

ensure_python_venv() {
  if python3 -c "import venv, ensurepip" >/dev/null 2>&1; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    log "installing python3-venv (ensurepip missing)"
    sudo apt-get update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq python3-venv python3-pip
  fi
  python3 -c "import venv, ensurepip" >/dev/null 2>&1
}

# Upstream koofr/__init__.py uses a Python 2 implicit relative import.
patch_python_koofr_init() {
  local init="${PY_DEST}/koofr/__init__.py"
  [[ -f "${init}" ]] || return 0
  if grep -q '^from client import KoofrClient' "${init}"; then
    sed -i 's/^from client import KoofrClient/from .client import KoofrClient/' "${init}"
    log "patched ${init} for Python 3 (from .client import KoofrClient)"
  fi
}

# python-koofr — distutils setup.py; Python 3.12 needs setuptools.
if [[ -f "${PY_DEST}/setup.py" ]]; then
  ensure_python_venv
  patch_python_koofr_init
  if [[ -x "${PY_VENV}/bin/python" ]] && "${PY_VENV}/bin/python" -c "from koofr.client import KoofrClient; import koofr" >/dev/null 2>&1; then
    log "python-koofr already installed in ${PY_VENV}"
  else
    rm -rf "${PY_VENV}"
    python3 -m venv "${PY_VENV}"
    "${PY_VENV}/bin/python" -m pip install --upgrade pip setuptools wheel
    "${PY_VENV}/bin/python" -m pip install -e "${PY_DEST}"
    "${PY_VENV}/bin/python" -c "from koofr.client import KoofrClient; import koofr; print('python-koofr', koofr.VERSION, KoofrClient)"
    log "installed python-koofr into ${PY_VENV}"
  fi
  export PATH="${PY_VENV}/bin:${PATH}"
else
  log "WARN: python-koofr sources missing; skipped pip install"
fi

log "done"
ls -1 "${VENDOR}"
