# Source

- Remote: https://github.com/lovecloudsjl/.github.git
- Snapshot ref: `30d62e6519295db9bff728f3abf817c94d6770da` (default branch at install time)
- Why a snapshot: the Cloud Agent git identity cannot clone `lovecloudsjl/*` remotes (`repository not found`). Files were copied through the GitHub API.
- Refresh: run `bash scripts/install-lovecloudsjl-github.sh`. If credentials can read the remote, the script replaces this snapshot with a live clone.
- Snapshot edit: the profile badge originally targeted `https://chathurikafiveer.github.io/.github/koofr-download` (404 at install time). It now points at the official site, `https://koofr.eu`.
