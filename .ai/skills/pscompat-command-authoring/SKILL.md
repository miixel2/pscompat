---
name: pscompat-command-authoring
description: Implement or update pscompat command scripts and shared helpers for the pscompat repository. Use when adding or modifying Linux-compatible PowerShell commands under cmds/ or helpers under lib/, especially when the work must preserve PowerShell 5.1 compatibility, Linux-like stdout/stderr and exit codes, pipeline behavior, comment-based help, and scoped MVP delivery.
---

# pscompat-command-authoring

Work from the repository contract first.

1. Read `AGENTS.md`, `CONVENTIONS.md`, `ADDING_COMMANDS.md`, and `IMPLEMENTATION_ROADMAP.md`.
2. Confirm whether the target command is a non-conflict command or a conflict-name command.
3. Implement the smallest correct scope that matches the roadmap phase and notes.
4. Keep the script compatible with Windows PowerShell 5.1.
5. Pair the implementation with test and doc updates, or explicitly note what remains.

## Apply These Rules

- Use `#Requires -Version 5.1`.
- Use `[CmdletBinding(SupportsShouldProcess)]` for user-facing scripts. Keep it for destructive commands.
- Use `Write-Output` for stdout.
- Use `Write-Error` or `Write-Warning` for stderr-like output.
- Never use `Write-Host`.
- Prefer Linux flag names first. PowerShell-friendly aliases are secondary.
- Avoid external binaries and PowerShell 7-only APIs.
- Use `Join-Path`, `Resolve-Path`, `Convert-Path`, or `[System.IO.Path]` instead of hardcoded separators.
- Make encoding and newline behavior explicit when relevant.
- Document Linux-vs-Windows deltas in comment-based help.

## Implementation Workflow

1. Confirm the minimal supported scope from the roadmap notes.
2. Create or update `cmds/<command>.ps1`.
3. Add shared helpers only when duplication is real across multiple commands.
4. Preserve text-stream behavior instead of leaning on PowerShell object semantics.
5. Add comments only for non-obvious compatibility choices.

## Conflict Command Rule

For command names that conflict with PowerShell aliases, functions, or Windows executables:

- do not rely on bare command invocation
- use explicit script-path invocation in examples and tests
- document the conflict in command docs when implemented

## Handoff Expectation

Before considering the task complete, coordinate with:

- `pscompat-pester-parity` for tests
- `pscompat-doc-roadmap-sync` for README, docs, and roadmap updates
