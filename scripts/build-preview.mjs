// Renders profile/README.md to dist/index.html using GitHub-flavored Markdown
// and github-markdown-css, so the profile page can be previewed exactly as it
// appears on a GitHub profile before pushing.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { Marked } from "marked";
import { gfmHeadingId } from "marked-gfm-heading-id";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, "..");

const source = resolve(root, "profile/README.md");
const outDir = resolve(root, "dist");
const outFile = resolve(outDir, "index.html");

const cssPath = resolve(
  root,
  "node_modules/github-markdown-css/github-markdown.css",
);

const markdown = readFileSync(source, "utf8");
const css = existsSync(cssPath) ? readFileSync(cssPath, "utf8") : "";

const marked = new Marked({ gfm: true, breaks: false });
marked.use(gfmHeadingId());

const body = marked.parse(markdown);

const html = `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Profile README preview</title>
    <style>
      ${css}
      body {
        box-sizing: border-box;
        min-width: 200px;
        max-width: 980px;
        margin: 0 auto;
        padding: 45px;
        background: #ffffff;
      }
      @media (prefers-color-scheme: dark) {
        body { background: #0d1117; }
      }
    </style>
  </head>
  <body>
    <article class="markdown-body">
      ${body}
    </article>
  </body>
</html>
`;

if (!existsSync(outDir)) {
  mkdirSync(outDir, { recursive: true });
}
writeFileSync(outFile, html, "utf8");

console.log(`Rendered ${source} -> ${outFile} (${html.length} bytes)`);
