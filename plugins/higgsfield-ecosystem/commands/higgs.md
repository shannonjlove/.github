---
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
