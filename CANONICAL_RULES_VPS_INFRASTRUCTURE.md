# CANONICAL RULES: VPS Infrastructure & Podman Quadlets

**Systemwide Template | Last Updated: 2026-07-05**

For all future VPS and infrastructure work (Hostinger / Nexus / Podman Quadlets).

---

## 1️⃣ Single Paste Block Only

All terminal instructions **MUST** be delivered as a single, copy‑pasteable block, not scattered commands.

- If multiple phases are required, each phase gets its own clearly labeled paste block (e.g., "Phase 1: networks," "Phase 2: Quadlet," etc.)
- Every phase is still a cohesive block

---

## 2️⃣ Explicit Machine Every Time

Every paste block **MUST** state explicitly where it runs:

- Example: "Paste this at the root prompt on your Nexus VPS."
- Example: "Paste this in your Mac terminal."
- **No assumptions.** The location is always spelled out in plain English at the top of the block.

---

## 3️⃣ Explicit Prompt Context

When referring to the VPS, instructions should tie to the actual prompt string.

- Example: "Run this where your prompt looks like `root@shannonjlove:~#`."
- When referring to the Mac, name the Mac prompt explicitly (e.g., `shannonjlove@Shannons-Mac-Pro ~ %`).

---

## 4️⃣ No Vague Verification Language

**Avoid phrases like "make sure," "verify," or "check" unless immediately followed by exact commands to do so.**

Pattern:
```
To verify X, run:
  [command]

If X is correct, you should see:
  [expected output]
```

Every verification step must be concrete: specific command + expected output shape.

---

## 5️⃣ Environment and Path Assumptions Must Be Stated

If a block assumes something exists (e.g., `/opt/sjl-mcp/server.py`), the assumption must be spelled out and validated with a command:

```
This assumes server.py is at /opt/sjl-mcp/server.py. Confirm with:

  ls -l /opt/sjl-mcp
```

---

## 6️⃣ No Mixed Runtimes or Tools (Unless Explicitly Requested)

For this stack:
- **Default to:** Podman + Quadlets
- **Avoid:** Docker, Caddy, Traefik, Compose unless the user explicitly asks to involve them
- If Docker is present on the system, mention only as context, not as the primary tool

---

## 7️⃣ Quadlet-Specific Rules

- **Rootful Quadlet unit files go in:** `/etc/containers/systemd/`
- **Env files for Quadlets go in:** `/etc/podman/secrets/` (or another explicit path, with permissions commands included)

Every Quadlet paste block must:
- Write the env file (with concrete keys)
- Lock permissions (`chmod 600`, `chown root:root`)
- Write the `.container` file
- Run `systemctl daemon-reload`
- Start/restart the service
- Show `systemctl status`, `journalctl`, and `podman` commands to confirm

---

## 8️⃣ Narration After the Block, Not Inside It

Explanations go **before or after** the paste block, **not interleaved** with commands inside it.

Inside the block, only comments that are directly useful at execution time are allowed (e.g., `# Optional localhost-only access`).

---

## 9️⃣ If a Step Might Still Be Running, Say So Explicitly

When a long-running command (like `podman build`) is in progress, instructions must explicitly say:

- "Wait until the command finishes and the prompt returns, then paste this next block."
- **No assumptions that the user knows whether the process is still running.**

---

## 🔟 Error-Handling Protocol

When a block might fail, the follow-up instructions must specify the exact commands to capture diagnostics:

```bash
systemctl status sjl-mcp-quadlet.service --no-pager
journalctl -u sjl-mcp-quadlet.service -n 100 --no-pager
podman ps -a | grep sjl-mcp
podman logs --tail=100 sjl-mcp
```

Ask the user to paste back those outputs verbatim, then respond with the next **single paste block** that fixes the issue.

---

## 🎯 Key Mantra

> **"For VPS work, always respond with a single paste block, clearly state which machine and prompt it runs on, and never say 'make sure' without giving the exact command and expected output."**

---

**Document Source:** Canonical_Rule_Handoff_for_VPS_Instructions  
**Session:** 2026-07-05  
**Status:** Active (All work follows these rules)
