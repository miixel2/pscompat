# Claude Project Instructions

Use this file as the project memory entry point for `pscompat`.

## Source Of Truth

Follow these files in this order:

1. `AGENTS.md`
2. `CONVENTIONS.md`
3. `ADDING_COMMANDS.md`
4. `IMPLEMENTATION_ROADMAP.md`

If instructions conflict, prefer the higher item in the list.

## Shared SmartAIWiki

- 🧠 This project uses shared SmartAIWiki at `~/agent-wiki`.
- 🔥 Before durable/project-context work, read `~/agent-wiki/hotcache.md`, `~/agent-wiki/AGENTS.md`, `~/agent-wiki/index.md`, and recent `~/agent-wiki/log.md`.
- 📥 If this project creates reusable knowledge, ask whether to ingest it into `~/agent-wiki`.

## Project-Local Skills

This repository keeps reusable agent playbooks under `.ai/skills/`.

Start with:

- `.ai/skills/README.md`

Then read only the relevant skill file for the task:

- `.ai/skills/pscompat-command-authoring/SKILL.md`
- `.ai/skills/pscompat-pester-parity/SKILL.md`
- `.ai/skills/pscompat-doc-roadmap-sync/SKILL.md`

## Working Rules

- Target Windows PowerShell 5.1 first.
- Prefer Linux-like stdout, stderr, exit codes, and pipeline behavior.
- Do not use external binaries, WSL, Cygwin, Git Bash, or GNU tools.
- Never use `Write-Host` for command output.
- Do not mark implementation complete until script, tests, docs, and roadmap are updated together.

## Name Conflict Rule

Some command names conflict with PowerShell aliases, functions, or Windows executables.

For conflict-name commands:

- do not rely on bare command invocation
- use explicit script-path invocation in tests and examples
- document the conflict clearly

See `IMPLEMENTATION_ROADMAP.md` for the current conflict list and sequencing policy.
