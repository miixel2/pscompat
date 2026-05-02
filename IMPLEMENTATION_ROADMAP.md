# pscompat Implementation Roadmap

## Purpose

This document is the execution plan and progress tracker for implementing `pscompat`.

It is written for AI agents and human contributors who need a concrete, repeatable plan for building the repository incrementally without drifting from the project constraints.

This file must be updated whenever a script, shared helper, or roadmap milestone is completed.

---

## Governing Rules

Follow these documents in this order:

1. `AGENTS.md`
2. `CONVENTIONS.md`
3. `ADDING_COMMANDS.md`
4. `README.md`

Non-negotiable rules:

- Target Windows PowerShell 5.1 first.
- Do not use external binaries, WSL, Cygwin, Git Bash, or GNU tools.
- Do not use `Write-Host` for command output.
- Prefer Linux-like stdout, stderr, exit code, and pipeline semantics.
- Do not mark work as complete until implementation, tests, and docs are updated.

---

## Roadmap Review Summary

The proposed roadmap is strong overall, but these adjustments should be applied before implementation:

### 1. Keep Phase 0 minimal

`lib/common.ps1` and `tests/_TestHelpers.ps1` should exist early.

`lib/pipeline.ps1` should only contain minimal reusable stdin helpers. Do not build a large helper framework before at least two commands need the same logic.

`CONTRIBUTING.md` is useful, but it is lower priority than command scaffolding, tests, and README accuracy.

### 2. Move `which.ps1` earlier

`which.ps1` is simple, useful, and low-risk. It should be implemented early because it helps both users and contributors validate PATH behavior.

### 3. Re-scope `find.ps1`

`find.ps1` is much harder on Windows than it looks because path semantics, metadata, recursion behavior, and time filters do not map cleanly. It should not be treated as a simple Phase 2 warm-up item.

### 4. Re-scope `echo.ps1`

Start with a minimal scope:

- plain output
- `-n`

Treat escape expansion such as `-e` as an explicit stretch goal because `echo` behavior is shell-dependent even on Linux.

### 5. Re-scope `env.ps1`

`env` cannot reliably modify the parent PowerShell session when implemented as a script.

Initial scope should be:

- print environment variables
- optionally run a child command with temporary environment overrides

Do not pretend the script can permanently mutate the caller's shell environment.

### 6. Re-scope `tar.ps1`

Do not wrap 7-Zip or any external archiver. That violates repository rules.

If `tar.ps1` is implemented, it must use built-in PowerShell and .NET capabilities only, with explicit documentation for any `.tar` limitations.

### 7. Re-scope `curl.ps1`

Treat `curl.ps1` as a scoped compatibility wrapper over `Invoke-WebRequest` or `Invoke-RestMethod`.

Full flag parity is out of scope. Implement only a documented subset.

### 8. Be explicit about command-name conflicts

The following commands need invocation guidance and documentation because they conflict with built-in PowerShell aliases, functions, or Windows tools in the current environment:

- `cat.ps1`
- `cp.ps1`
- `curl.ps1`
- `diff.ps1`
- `echo.ps1`
- `find.ps1`
- `kill.ps1`
- `mkdir.ps1`
- `mv.ps1`
- `ps.ps1`
- `rm.ps1`
- `sort.ps1`
- `tar.ps1`
- `tee.ps1`

Document how users are expected to invoke them:

- full path
- explicit script path in tests and examples
- or another documented strategy that does not rely on bare-name resolution

### 9. Defer conflicting command names to the final implementation phase

For this roadmap, any command that conflicts with an existing PowerShell alias, function, or Windows executable is treated as a final-phase item unless a user explicitly overrides that decision.

This rule overrides the earlier functional priority of those commands.

---

## Prioritization Criteria

Priority is determined by three dimensions:

| Dimension | Meaning |
|---|---|
| Foundation value | Whether the script is a building block for other commands or tests |
| Complexity | Whether it is a good warm-up item or a major milestone |
| Dependency | Whether other commands rely on it for testing or composition |

Use the following decision rule when sequencing work:

1. Prefer high-foundation, low-complexity scripts first.
2. Delay Windows-specific edge-case commands until the scaffold is proven.
3. Do destructive file-system commands only after helper and test patterns are stable.

---

## Revised Phase Plan

### Phase 0 - Scaffolding

These are infrastructure tasks, not user-facing commands.

| ID | Item | Status | Notes |
|---|---|---|---|
| 0.1 | Create `cmds/`, `lib/`, `tests/`, `docs/`, `config/` if missing | Done | Created tracked scaffold with minimal placeholder files where needed |
| 0.2 | Create `lib/common.ps1` | Done | Added minimal helpers for path resolution, stderr formatting, and exit code handling |
| 0.3 | Create `tests/_TestHelpers.ps1` | Done | Added shared process-based script invocation and temp directory helpers |
| 0.4 | Create `lib/pipeline.ps1` | Done | Added minimal line-buffer helpers for stdin-oriented commands |
| 0.5 | Align `README.md` with actual repo structure | Done | README now reflects the real scaffold and root documentation paths |
| 0.6 | Add `CONTRIBUTING.md` skeleton | Planned | Optional but useful after scaffold is stable |
| 0.7 | Document command-name conflict strategy in repo docs | Done | Added explicit conflict invocation guidance to README and root command authoring docs |
| 0.8 | Add project-local multi-agent instruction and skill files | Done | Added shared `.ai/skills/`, `CLAUDE.md`, and `.github/copilot-instructions.md` |

### Phase 1 - Non-Conflict Core Primitives

These should be implemented first because they are common, testable, and do not collide with existing PowerShell command names.

| ID | Script | Linux Command | Status | Notes |
|---|---|---|---|---|
| 1.1 | `touch.ps1` | `touch` | Done | Supports default create/update behavior plus `-c`, `--no-create`, and `-NoCreate` |
| 1.2 | `head.ps1` | `head` | Done | Supports file input, stdin input, `-n`, and multi-file headers |
| 1.3 | `tail.ps1` | `tail` | Done | Supports file input, stdin input, `-n`, and multi-file headers |
| 1.4 | `wc.ps1` | `wc` | Done | Supports default output plus `-l`, `-w`, `-c`, stdin, and `total` |
| 1.5 | `which.ps1` | `which` | Done | Resolves first PATH match for applications and external scripts |

### Phase 2 - Non-Conflict Search and Filters

Implement high-value text processing that does not rely on conflicting command names.

| ID | Script | Linux Command | Status | Notes |
|---|---|---|---|---|
| 2.1 | `grep.ps1` | `grep` | Done | Supports regex search, file/stdin input, multi-file prefixes, `-i`, `-n`, and `-v` |
| 2.2 | `cut.ps1` | `cut` | Done | Supports delimiter and field extraction with simple lists and ranges |
| 2.3 | `uniq.ps1` | `uniq` | Done | Supports adjacent duplicate filtering with `-c`, `-d`, `-u`, and `-i` |
| 2.4 | `tr.ps1` | `tr` | Done | Supports character translation, deletion, simple ranges, and common escapes |

### Phase 3 - Non-Conflict System and Utility Commands

These are useful and avoid immediate naming conflicts, but still need careful Windows-compatible scoping.

| ID | Script | Linux Command | Status | Notes |
|---|---|---|---|---|
| 3.1 | `ln.ps1` | `ln` | Planned | Document privilege and capability limitations |
| 3.2 | `chmod.ps1` | `chmod` | Planned | Stub or warn-only unless ACL mapping is well-defined |
| 3.3 | `env.ps1` | `env` | Planned | Print vars and optionally run child command |
| 3.4 | `uptime.ps1` | `uptime` | Planned | Stable output format matters |
| 3.5 | `df.ps1` | `df` | Planned | Include human-readable option later |
| 3.6 | `du.ps1` | `du` | Planned | Start with per-path summary |

### Phase 4 - Non-Conflict Advanced Text and Composition

These commands should stay intentionally scoped and explicitly documented.

| ID | Script | Linux Command | Status | Notes |
|---|---|---|---|---|
| 4.1 | `xargs.ps1` | `xargs` | Planned | Start with whitespace/newline-safe subset only |
| 4.2 | `sed.ps1` | `sed` | Planned | Start with simple substitution only |
| 4.3 | `awk.ps1` | `awk` | Planned | Must be intentionally limited in scope |

### Phase 5 - Conflict Command Implementation (Suspended)

All commands in this phase conflict with an existing PowerShell alias, function, or Windows executable.

This phase is currently **suspended** per project direction; conflict-name command implementation is deferred indefinitely unless explicitly re-enabled.

When/if resumed, implement them last and document invocation strategy clearly.

| ID | Script | Linux Command | Status | Notes |
|---|---|---|---|---|
| 5.1 | `cat.ps1` | `cat` | Deferred | Phase suspended: conflict command implementation paused |
| 5.2 | `echo.ps1` | `echo` | Deferred | Phase suspended: Start with plain output and `-n` only |
| 5.3 | `sort.ps1` | `sort` | Deferred | Phase suspended: Focus on text output parity, not object sorting |
| 5.4 | `find.ps1` | `find` | Deferred | Phase suspended: Tight scope only; also conflicts with `find.exe` |
| 5.5 | `tee.ps1` | `tee` | Deferred | Phase suspended: Useful in pipelines, but name collides with alias |
| 5.6 | `mkdir.ps1` | `mkdir` | Deferred | Phase suspended: Support `-p` semantics |
| 5.7 | `cp.ps1` | `cp` | Deferred | Phase suspended: Start with file copy, then recursive support |
| 5.8 | `mv.ps1` | `mv` | Deferred | Phase suspended: Handle same-volume and cross-volume behavior carefully |
| 5.9 | `rm.ps1` | `rm` | Deferred | Phase suspended: `-WhatIf` and `SupportsShouldProcess` required |
| 5.10 | `ps.ps1` | `ps` | Deferred | Phase suspended: Define an output contract first |
| 5.11 | `kill.ps1` | `kill` | Deferred | Phase suspended: Map supported signals only |
| 5.12 | `diff.ps1` | `diff` | Deferred | Phase suspended: Focus on useful unified diff output |
| 5.13 | `tar.ps1` | `tar` | Deferred | Phase suspended: Built-in archive APIs only |
| 5.14 | `curl.ps1` | `curl` | Deferred | Phase suspended: Documented subset only |

---

## Dependency Notes

These dependencies are important enough to guide sequencing:

```text
lib/common.ps1
    -> almost every script

tests/_TestHelpers.ps1
    -> almost every test

grep.ps1
    -> sed.ps1
    -> broader test coverage for text pipelines

Conflict-name commands
    -> must not block non-conflict command implementation
    -> must be invokable by explicit script path during testing
```

Do not create artificial dependencies where a command can be implemented and tested independently.

In particular:

- `grep.ps1` must not depend on `cat.ps1` existing
- `uniq.ps1` must not depend on `sort.ps1` existing
- `xargs.ps1` must not depend on `find.ps1` existing

---

## Recommended Sprint Order

Use this sprint order unless a specific user request overrides it:

| Sprint | Scope |
|---|---|
| Sprint 0 | Phase 0 scaffold and repo alignment |
| Sprint 1 | `touch`, `head`, `tail`, `wc`, `which` |
| Sprint 2 | `grep`, `cut`, `uniq`, `tr` |
| Sprint 3 | `ln`, `chmod`, `env`, `uptime`, `df`, `du` |
| Sprint 4 | `xargs`, `sed`, `awk` |
| Sprint 5 | **Suspended** (conflict commands deferred indefinitely) |

Rationale:

- Sprint 1 establishes non-conflict primitives first.
- Sprint 2 establishes the core non-conflict text pipeline.
- Sprint 3 builds out useful non-conflict system commands before risky collisions.
- Sprint 4 keeps advanced scoped work ahead of name-conflict commands.
- Sprint 5 is currently suspended; conflicting command names are deferred indefinitely.

---

## Name Conflict Strategy

The following commands are classified as name-conflict commands in PowerShell on this machine:

- `cat`
- `cp`
- `curl`
- `diff`
- `echo`
- `find`
- `kill`
- `mkdir`
- `mv`
- `ps`
- `rm`
- `sort`
- `tar`
- `tee`

### Execution rule

Until a dedicated resolution strategy is added, agents and contributors must not rely on bare command names for these commands.

Use explicit invocation during development and testing, for example:

```powershell
.\cmds\cat.ps1
```

or:

```powershell
& "$PSScriptRoot\..\cmds\cat.ps1"
```

### Documentation rule

Whenever a conflict command is implemented:

- document that the command name collides with an existing PowerShell alias, function, or executable
- show explicit script-path invocation examples
- do not imply that adding `cmds/` to `PATH` guarantees bare-name resolution

### Design rule

Do not build the rest of the repository around conflict commands being available early.

Non-conflict commands should be independently testable without requiring:

- `cat.ps1`
- `sort.ps1`
- `find.ps1`
- or any other conflict command

### Deferred strategy options

These options are intentionally deferred until after the conflict command phase:

- session-level alias removal
- wrapper launchers
- module-based export strategy
- prefix-based alternate command names for development

For now, explicit script-path invocation is the default and required strategy.

---

## Per-Command Definition of Done

Do not mark a command complete until all items below are done:

- Script exists under `cmds/`
- Script is compatible with PowerShell 5.1
- Linux delta is documented in comment-based help
- Pester tests exist and cover behavior, not just implementation
- README command table is updated
- Command-specific documentation exists or is updated
- This roadmap file is updated

Status values:

- `Planned`
- `In Progress`
- `Blocked`
- `Done`
- `Deferred`

---

## Agent Execution Workflow

Whenever working on an item from this roadmap, agents must:

1. Read `AGENTS.md`, `CONVENTIONS.md`, and `ADDING_COMMANDS.md`
2. Review this roadmap and select the next `Planned` or `Blocked` item to address
3. Implement the smallest correct scope for that item
4. Add or update tests
5. Update docs
6. Update this roadmap before ending the task

If a script is intentionally scoped down, document:

- what is implemented now
- what is explicitly deferred
- why the scope was limited

---

## Mandatory Roadmap Update Procedure

At the end of every completed task, update this file in all relevant places:

### A. Update the task status

Change the relevant row from:

- `Planned` -> `In Progress`
- `In Progress` -> `Done`
- `Planned` or `In Progress` -> `Blocked` if needed

### B. Add a progress log entry

Append a new item under `Progress Log` with:

- date
- item ID
- files added or changed
- brief scope summary
- notable Linux-vs-Windows deltas
- follow-up work if any

### C. Update phase notes if needed

If a phase is materially completed or re-scoped, update the phase notes or sprint order.

### D. Keep plan and reality synchronized

If implementation discovers that the roadmap is wrong, update the roadmap instead of leaving stale intent behind.

---

## Progress Log

Use this section as the running implementation history.

- 2026-04-18 - Initial roadmap created. Status baseline established from proposed implementation plan. No command implementation completed yet.
- 2026-04-18 - Roadmap updated to defer all PowerShell name-conflict commands to the final implementation phase. Added explicit invocation and documentation strategy for conflict commands.
- 2026-04-18 - Added project-local multi-agent support files for Codex, GitHub Copilot, and Claude. Created shared skills under `.ai/skills/`, added `CLAUDE.md`, added `.github/copilot-instructions.md`, and updated `AGENTS.md` to reference the project-local playbooks.
- 2026-04-18 - Completed Phase 0 scaffold items 0.1, 0.2, 0.3, 0.4, 0.5, and 0.7. Added `cmds/.gitkeep`, `config/.gitkeep`, `lib/common.ps1`, `lib/pipeline.ps1`, `tests/_TestHelpers.ps1`, `CONVENTIONS.md`, and `ADDING_COMMANDS.md`. Updated `README.md` plus mirrored docs files under `docs/` to clarify root canonical references. Linux-vs-Windows delta: conflict-name commands must still be invoked by explicit script path; no user-facing command behavior is implemented yet. Follow-up work: add `CONTRIBUTING.md` if needed, then begin Sprint 1 with `touch.ps1`.
- 2026-04-18 - Completed item 1.1 for `touch.ps1`. Added `cmds/touch.ps1`, `tests/touch.Tests.ps1`, and `docs/touch.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: default create/update behavior, multi-path handling, and `-c` / `--no-create` / `-NoCreate`. Linux-vs-Windows delta: advanced timestamp flags (`-a`, `-m`, `-d`, `-t`, `-r`) are deferred, and timestamp precision follows Windows/.NET behavior. Follow-up work: proceed to `head.ps1`.
- 2026-04-18 - Completed item 1.2 for `head.ps1`. Added `cmds/head.ps1`, `tests/head.Tests.ps1`, and `docs/head.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: default 10-line output, `-n`, file input, stdin-like pipeline input, and Linux-style multi-file headers. Linux-vs-Windows delta: byte mode (`-c`), negative counts, and quiet/verbose header controls (`-q`, `-v`) are deferred. Follow-up work: proceed to `tail.ps1`.
- 2026-04-18 - Completed item 1.3 for `tail.ps1`. Added `cmds/tail.ps1`, `tests/tail.Tests.ps1`, and `docs/tail.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: default last-10-line output, `-n`, file input, stdin-like pipeline input, `-n 0`, and Linux-style multi-file headers. Linux-vs-Windows delta: follow mode (`-f`), byte mode (`-c`), and relative count forms such as `-n +5` are deferred. Follow-up work: proceed to `wc.ps1`.
- 2026-04-18 - Completed item 1.4 for `wc.ps1`. Added `cmds/wc.ps1`, `tests/wc.Tests.ps1`, and `docs/wc.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: default line/word/byte output, explicit `-l` / `-w` / `-c`, stdin-like pipeline input, multi-file processing, and `total`. Linux-vs-Windows delta: `-m` and `-L` are deferred, and pipeline counting under native PowerShell remains a reconstructed text stream rather than raw Unix pipe bytes. Follow-up work: proceed to `which.ps1`.
- 2026-04-18 - Completed item 1.5 for `which.ps1`. Added `cmds/which.ps1`, `tests/which.Tests.ps1`, and `docs/which.md`; updated `README.md`, `IMPLEMENTATION_ROADMAP.md`, and `tests/_TestHelpers.ps1`. Scope implemented: first-match PATH resolution for applications and external scripts, multi-name processing, and non-zero exit on misses. Linux-vs-Windows delta: `-a` is deferred, and PowerShell alias/function resolution is intentionally excluded to keep PATH behavior predictable. Follow-up work: Sprint 1 core primitives are complete; proceed to `grep.ps1`.
- 2026-05-02 - Completed item 2.1 for `grep.ps1`. Added `cmds/grep.ps1`, `tests/grep.Tests.ps1`, and `docs/grep.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: .NET regex search, file input, stdin-like pipeline input, multi-file prefixes, `-i`, `-n`, and `-v`. Linux-vs-Windows delta: .NET regex syntax differs from GNU grep in edge cases; recursive mode, fixed-string mode, count mode, quiet mode, and binary file handling are deferred. Follow-up work: proceed to `cut.ps1`.
- 2026-05-02 - Completed item 2.2 for `cut.ps1`. Added `cmds/cut.ps1`, `tests/cut.Tests.ps1`, and `docs/cut.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: delimiter mode with `-d`, field mode with `-f`, comma-separated field lists, simple ranges, file input, and stdin-like pipeline input. Linux-vs-Windows delta: byte mode, character mode, suppress-undelimited mode, complement mode, and custom output delimiters are deferred. Follow-up work: proceed to `uniq.ps1`.
- 2026-05-02 - Completed item 2.3 for `uniq.ps1`. Added `cmds/uniq.ps1`, `tests/uniq.Tests.ps1`, and `docs/uniq.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: adjacent duplicate filtering independent of `sort.ps1`, one input file or stdin-like pipeline input, `-c`, `-d`, `-u`, and `-i`. Linux-vs-Windows delta: skip-field/skip-character options, repeated group variants, and output-file operand support are deferred. Follow-up work: proceed to `tr.ps1`.
- 2026-05-02 - Completed item 2.4 for `tr.ps1`. Added `cmds/tr.ps1`, `tests/tr.Tests.ps1`, and `docs/tr.md`; updated `README.md` and `IMPLEMENTATION_ROADMAP.md`. Scope implemented: stdin-like character translation, deletion with `-d`, simple ascending ranges, and common escapes. Linux-vs-Windows delta: complement mode, squeeze mode, character classes, octal escapes, and raw Unix byte-stream parity are deferred. Follow-up work: Sprint 2 search and filters are complete; proceed to `ln.ps1`.

---

- 2026-05-02 - Phase 5 (conflict command implementation) suspended by project direction. Updated all Phase 5 items from `Planned` to `Deferred` and marked Sprint 5 as suspended. Follow-up work: continue with Phase 3 non-conflict commands starting at `ln.ps1`.

## Strategy Decisions

These decisions should be documented before or during the relevant phase.

### Command invocation strategy

Resolved for now:

- non-conflict commands may be invoked directly once `cmds/` is on `PATH`
- conflict commands must be invoked by explicit script path during development, testing, and documentation until a later resolution strategy is adopted

### Safety semantics for destructive commands

Decide whether Linux-like behavior or PowerShell safety affordances take precedence when they conflict.

Current default:

- support `SupportsShouldProcess`
- support `-WhatIf` for destructive operations
- document any Linux behavior mismatch explicitly

### Encoding policy

Decide and document the default UTF-8 strategy for:

- reading files
- writing files
- stdin
- stdout

### Scope boundary for heavy wrappers

Define explicit minimum viable scope before implementing:

- `awk.ps1`
- `sed.ps1`
- `tar.ps1`
- `curl.ps1`

---

## Notes For Future Agents

- Do not skip Phase 0.
- Do not treat Windows behavior as automatically acceptable.
- Do not over-abstract helper libraries too early.
- Do not mark roadmap items done until tests and docs are also complete.
- `grep.ps1` is the centerpiece of the text-processing stack. Invest in it carefully.
