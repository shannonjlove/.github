---
name: "higgsfield-recall"
description: "Use this skill AUTOMATICALLY before writing any Higgsfield prompt. Query the memory databases for relevant past failures and pre-apply known fixes before the user even hits generate. Triggers include: any request to write a Higgsfield prompt, any use of the higgsfield-prompt skill, any mention of generating a video or image on Higgsfield, any MCSLA prompt construction. This skill should run SILENTLY in the background — don't announce it, just apply what's known. If the databases are empty, skip silently and proceed with normal prompt generation."
---

# /higgsfield-recall

Use the `higgsfield-recall` skill from this plugin (`skills/higgsfield-recall/SKILL.md`).
Write or refine the Higgsfield prompt with that skill, then execute via Higgsfield MCP or `higgsfield generate create`.
