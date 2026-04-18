# Project Agent Skills

This directory contains project-local agent playbooks for `pscompat`.

These files are the shared source of truth for task-specific workflows across:

- Codex
- GitHub Copilot
- Claude

Use the smallest relevant skill set for the task. Do not load every skill by default.

## Available Skills

### `pscompat-command-authoring`

Read [pscompat-command-authoring/SKILL.md](./pscompat-command-authoring/SKILL.md) when:

- adding a new command under `cmds/`
- modifying an existing command
- creating or updating shared helpers under `lib/`
- making implementation decisions that must preserve PowerShell 5.1 compatibility and Linux-like CLI behavior

### `pscompat-pester-parity`

Read [pscompat-pester-parity/SKILL.md](./pscompat-pester-parity/SKILL.md) when:

- creating or updating `tests/*.Tests.ps1`
- verifying stdout, stderr, exit codes, invalid usage, and pipeline behavior
- adding regression coverage for command behavior

### `pscompat-doc-roadmap-sync`

Read [pscompat-doc-roadmap-sync/SKILL.md](./pscompat-doc-roadmap-sync/SKILL.md) when:

- updating `README.md`
- updating command docs
- updating `IMPLEMENTATION_ROADMAP.md`
- closing out a task and syncing repository truth with implementation reality

## Selection Guidance

- Implementation task: start with `pscompat-command-authoring`
- Testing task: use `pscompat-pester-parity`
- Close-out, status, docs, or roadmap updates: use `pscompat-doc-roadmap-sync`
- Multi-step feature work: use more than one skill, but only the ones needed for the current step

## Repository Rules Still Win

These skills do not replace repository-wide instructions.

Always follow, in this order:

1. `AGENTS.md`
2. `CONVENTIONS.md`
3. `ADDING_COMMANDS.md`
4. `IMPLEMENTATION_ROADMAP.md`
