---
name: pscompat-pester-parity
description: Create or update Pester v5 tests for pscompat commands. Use when validating Linux-like behavior in the pscompat repository, including stdout/stderr separation, exit codes, invalid usage, file and pipeline input handling, regression coverage, and PowerShell 5.1-safe behavior.
---

# pscompat-pester-parity

Test behavior, not implementation details.

1. Read `AGENTS.md`, `CONVENTIONS.md`, `ADDING_COMMANDS.md`, and `IMPLEMENTATION_ROADMAP.md`.
2. Read the target command script and determine the intended MVP scope.
3. Write or update `tests/<command>.Tests.ps1` using Pester v5 style.
4. Assert observable CLI behavior first.
5. Add regression coverage before or with bug fixes when practical.

## Required Coverage

Cover these cases whenever they apply:

- happy path behavior
- invalid usage
- missing file or missing input behavior
- pipeline input
- stdout behavior
- stderr behavior
- exit codes
- documented Linux-vs-Windows deltas

## Test Design Rules

- Prefer explicit script-path invocation, especially for conflict-name commands.
- Do not assume commands earlier in the Linux ecosystem exist in this repository yet.
- Keep tests independent when possible.
- Avoid asserting private helper function behavior unless there is no better external assertion.
- Use fixtures or helper setup only when they reduce repetition without hiding behavior.

## Independence Rules

- `grep.ps1` tests must not require `cat.ps1` to exist.
- `uniq.ps1` tests must not require `sort.ps1` to exist.
- `xargs.ps1` tests must not require `find.ps1` to exist.

## Completion Expectation

Before closing the task, coordinate with `pscompat-doc-roadmap-sync` so the roadmap and docs reflect what the tests now prove.
