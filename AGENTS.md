# AGENTS.md

## Mission

`pscompat` provides native PowerShell implementations of familiar Linux shell commands.

The goal is not just "similar functionality". The goal is to preserve the parts that matter in real CLI usage:

- output shape
- exit codes
- pipeline behavior
- error semantics
- day-to-day usability on Windows without WSL, Cygwin, Git Bash, or external Unix binaries

This repository should feel predictable to someone who already knows the Linux command being emulated.

---

## Current Repository State

This repository is still early-stage and currently contains mostly project documentation and conventions.

Important implications:

- Do not assume `cmds/`, `lib/`, `tests/`, or `docs/` already exist just because `README.md` references them.
- If a task requires those directories and they are missing, create the minimum scaffold needed as part of the change.
- The current source-of-truth documents are the files that already exist in the repository root, especially:
  - `README.md`
  - `CONVENTIONS.md`
  - `ADDING_COMMANDS.md`

When there is a mismatch between aspirational structure in documentation and the actual repo contents, align changes with the real repository state first, then update docs.

---

## Shared SmartAIWiki

- 🧠 This project uses shared SmartAIWiki at `~/agent-wiki`.
- 🔥 Before durable/project-context work, read `~/agent-wiki/hotcache.md`, `~/agent-wiki/AGENTS.md`, `~/agent-wiki/index.md`, and recent `~/agent-wiki/log.md`.
- 📥 If this project creates reusable knowledge, ask whether to ingest it into `~/agent-wiki`.

---

## Project Agent Skills

This repository includes project-local task playbooks under:

- `.ai/skills/README.md`
- `.ai/skills/pscompat-command-authoring/SKILL.md`
- `.ai/skills/pscompat-pester-parity/SKILL.md`
- `.ai/skills/pscompat-doc-roadmap-sync/SKILL.md`

Use these files as focused workflow guides instead of repeating the same task logic from scratch every time.

Selection guidance:

- implementation work -> read `pscompat-command-authoring`
- Pester work -> read `pscompat-pester-parity`
- doc, roadmap, and close-out work -> read `pscompat-doc-roadmap-sync`

Do not load every skill by default. Read only the relevant skill for the current task.

These project-local skills supplement repository instructions. They do not override this file.

---

## Primary Objective

When adding or modifying a command, optimize in this order:

1. Linux behavior compatibility
2. PowerShell 5.1 compatibility
3. Clear and stable CLI ergonomics
4. Testability
5. Internal implementation elegance

PowerShell-idiomatic implementation is useful, but Linux-compatible user-facing behavior has higher priority.

---

## Hard Constraints

These are non-negotiable unless the user explicitly asks to change project direction.

### Runtime

- Target **Windows PowerShell 5.1 first**.
- PowerShell 7 compatibility is welcome, but never at the expense of 5.1 support.
- Avoid APIs, syntax, or behaviors that only work reliably in PowerShell 7+.

### Dependencies

- Do not introduce external runtime dependencies.
- Do not rely on WSL, Cygwin, Git Bash, MSYS, GNU utilities, or bundled executables.
- Prefer pure PowerShell and .NET APIs available to PowerShell 5.1.

### Command model

- Each emulated command should live in its own script, typically `cmds/<command>.ps1`.
- Shared logic should live in `lib/` only when duplication is real and recurring.
- Do not over-engineer abstractions before at least two commands need the same behavior.

---

## Behavior Contract

Every command should emulate Linux behavior as closely as is practical on Windows.

### Required behavior areas

- **stdout shape** should be stable and intentional.
- **stderr behavior** should be separated from normal output.
- **exit codes** should be predictable and Linux-like.
- **pipeline input** should work when the Linux command conceptually accepts stdin.
- **flag semantics** should resemble the Linux command before introducing PowerShell-specific conveniences.

### Exit codes

Use this default contract unless a command has a stronger Linux-specific rule:

- `0` for success
- `1` for runtime or general error
- `2` for bad usage or invalid arguments

If the real Linux command has a more nuanced exit code contract and it is practical to emulate, prefer the Linux behavior and document it.

### Output channels

Use:

- `Write-Output` for stdout
- `Write-Error` or `Write-Warning` for stderr-like signaling

Never use:

- `Write-Host`

Do not mix informational chatter into normal command output. Command output should be pipeable.

### Error message format

Prefer this format:

`<command>: <reason>`

Examples:

- `tail: file not found`
- `grep: invalid pattern`

Error text should be concise, user-facing, and actionable. Avoid leaking internal stack traces unless the task is specifically about debugging internals.

---

## PowerShell Authoring Rules

### Required script shape

Command scripts should follow this baseline unless there is a strong reason not to:

```powershell
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(...)
```

Add comment-based help for user-facing scripts.

### Parameter design

- Match Linux flag names where practical, such as `-n`, `-r`, `-f`.
- Optionally provide clearer PowerShell-friendly aliases such as `-Lines` for `-n`, but Linux-style flags remain primary.
- Keep parameter behavior unsurprising for CLI users.
- Validate arguments explicitly when malformed input would otherwise produce confusing PowerShell-native failures.

### Pipeline behavior

- Use `ValueFromPipeline` only when the emulated Linux command would reasonably accept stdin.
- Preserve composability. Commands should behave well when chained.
- Think carefully about line-by-line versus object-by-object behavior. This project emulates text-centric shell commands, not typical PowerShell object pipelines.

### Path handling

- Always use `Join-Path`, `Resolve-Path`, `Convert-Path`, or `[System.IO.Path]` as appropriate.
- Never hardcode `/` or `\` into path logic when path APIs should be used.
- Normalize paths before use when behavior depends on the resolved target.
- Be careful with wildcard expansion differences between PowerShell and Linux tools.

### Encoding and newlines

This project is especially sensitive to encoding drift.

- Prefer explicit UTF-8 behavior whenever feasible.
- Be aware that Windows PowerShell 5.1 does not default to UTF-8.
- Normalize line ending behavior intentionally.
- Do not assume CRLF output is acceptable just because PowerShell produced it.
- If a command cannot fully match Linux behavior because of platform constraints, document the delta clearly.

### Error handling

Use explicit failure paths. Favor predictable command behavior over implicit PowerShell exceptions.

Typical pattern:

```powershell
$ErrorActionPreference = 'Stop'

try {
    # implementation
}
catch {
    Write-Error "<command>: $($_.Exception.Message)"
    exit 1
}
```

If argument validation fails, prefer returning an appropriate usage error and exit code `2`.

---

## Implementation Guidance

### Prefer minimal, testable implementations

- Implement the smallest behaviorally-correct version first.
- Add edge cases only when they are part of expected CLI behavior or are likely to break users.
- Avoid building framework-like plumbing for a repository this small unless repetition justifies it.

### Mirror Linux where it matters most

Highest-value parity areas:

- displayed output
- error text shape
- exit code semantics
- accepted flags
- stdin and file input behavior

Lower priority areas:

- matching every obscure GNU edge case on day one
- replicating Linux internals that do not make sense on Windows

### Document deltas honestly

If Windows or PowerShell makes perfect parity impractical:

- keep the behavior reasonable
- keep it stable
- document the difference in the script help and command documentation

Do not silently ship behavior that differs from Linux in surprising ways.

---

## Testing Contract

Behavior without tests is not considered complete.

### Required coverage for each command

Every command should have Pester tests covering at least:

- happy path behavior
- invalid usage
- missing file or missing input scenarios
- pipeline input, when applicable
- exit codes
- stderr and stdout separation, when relevant

### Testing expectations

- Use **Pester v5** style tests.
- Keep tests focused on external behavior, not implementation internals.
- Prefer asserting command output, error behavior, and exit status rather than private helper details.
- Add regression tests for bugs before or with the fix when practical.

### Completion standard

A command is not "done" when only the script exists. It is done when:

1. implementation exists
2. tests exist
3. docs are updated
4. README command status is updated if needed

---

## Documentation Contract

When adding a new command, update documentation in the same change whenever practical.

Expected documentation work:

- update `README.md` command table
- add or update command-specific usage documentation
- describe Linux behavioral deltas clearly
- keep examples realistic and copy-paste friendly

When repository structure changes over time, do not assume docs live under `docs/` unless that directory actually exists in the current repo state.

---

## Review Heuristics

When reviewing work in this repository, pay extra attention to:

- accidental use of PowerShell 7-only features
- hidden dependence on external binaries
- incorrect stdout versus stderr behavior
- wrong exit codes
- poor pipeline behavior
- path normalization bugs
- encoding and newline inconsistencies
- documentation drift
- tests that only verify PowerShell mechanics instead of CLI behavior

The most common failure mode in this repo is a script that "works on my machine" but does not behave like the Linux command in real usage.

---

## Anti-Patterns

Avoid these unless the user explicitly asks otherwise:

- using `Write-Host`
- assuming PowerShell object semantics are a drop-in replacement for text stream behavior
- introducing PowerShell 7-only syntax without guarding compatibility
- using external Unix commands for convenience
- implementing undocumented behavior that diverges from Linux
- updating code without updating tests and docs
- silently ignoring edge cases that affect CLI predictability

---

## Task Guidance For Agents

When asked to add or modify a command, follow this order:

1. inspect the relevant docs and conventions already in the repo
2. confirm the intended Linux behavior
3. implement the smallest correct PowerShell 5.1-compatible version
4. add or update Pester tests
5. update README and command docs
6. call out any unavoidable Linux-vs-Windows behavioral delta

When asked to review code, prioritize findings about:

- behavior regressions
- Linux parity gaps
- compatibility issues
- missing tests

When asked to bootstrap missing repository structure, create only the minimal directories and starter files needed for the requested task. Do not scaffold speculative architecture.

---

## Preferred Change Style

- Keep changes focused and reversible.
- Prefer a few clear helper functions over deep abstraction.
- Name things after the Linux command behavior, not clever internal metaphors.
- Comments should explain non-obvious behavior, especially Linux-compatibility decisions.
- If a design choice is driven by PowerShell 5.1 limitations, say so in code comments or docs where useful.

---

## Definition Of Done

A change is complete when it is:

- behaviorally correct
- compatible with PowerShell 5.1
- covered by Pester tests
- documented
- consistent with repository conventions

If any of those are missing, explicitly say what remains.
