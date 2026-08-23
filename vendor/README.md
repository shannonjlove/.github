# Vendored remotes

| Directory | Remote | Kind | Install |
| --- | --- | --- | --- |
| `go-koofrclient` | https://github.com/shannonjlove/go-koofrclient.git | Go Koofr API client | GOPATH overlay + `go install` |
| `python-koofr` | https://github.com/shannonjlove/python-koofr.git | Python Koofr SDK | editable pip install into `python-koofr/.venv` |

Refresh with `bash scripts/install-koofr-clients.sh`. Cloud Agent `install` in `.cursor/environment.json` runs the same script.

`python-koofr` ships a Python 2 implicit relative import in `koofr/__init__.py`. The install script rewrites that to `from .client import KoofrClient` so `import koofr` works on Python 3. The submodule commit is not changed.

Live API tests (`KOOFR_EMAIL` / `KOOFR_PASSWORD` / `KOOFR_APIBASE`) are not run during install.
