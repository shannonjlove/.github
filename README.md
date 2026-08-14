# Profile `.github` repository

This repository holds the GitHub profile README that renders on the account
profile page. The published content lives in [`profile/README.md`](profile/README.md).

## Development

This repo includes lightweight tooling to lint and preview the profile README
locally before pushing, so you can see it the way GitHub renders it.

Requirements: Node.js 20+ (the Cloud Agent environment uses Node 22).

```bash
npm ci        # install dev tooling
npm run lint  # validate profile/**/*.md with markdownlint
npm run build # render profile/README.md -> dist/index.html
npm run preview  # build, then serve the preview at http://localhost:4173
```

The preview uses GitHub-Flavored Markdown (`marked`) styled with
`github-markdown-css` to closely match GitHub's rendering.

## Cloud Agent environment

`.cursor/environment.json` configures the Cursor Cloud Agent environment:

- `install`: `npm ci` installs the dev tooling.
- `terminals.preview`: runs `npm run preview` to build and serve the rendered
  profile on port `4173`.
