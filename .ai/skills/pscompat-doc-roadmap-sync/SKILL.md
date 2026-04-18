---
name: pscompat-doc-roadmap-sync
description: Sync pscompat documentation and execution tracking after implementation work. Use when updating README entries, command-specific docs, Linux-vs-Windows delta notes, and IMPLEMENTATION_ROADMAP.md statuses or progress logs so the repository plan stays aligned with reality.
---

# pscompat-doc-roadmap-sync

Keep repository truth synchronized after every completed task.

1. Read `AGENTS.md`, `CONVENTIONS.md`, `ADDING_COMMANDS.md`, and `IMPLEMENTATION_ROADMAP.md`.
2. Identify which command, scaffold item, or roadmap milestone changed.
3. Update the relevant docs in the same task whenever practical.
4. Update roadmap status and progress log before ending the task.
5. If reality differs from the roadmap, update the roadmap instead of leaving stale intent behind.

## Always Review These Targets

- `README.md`
- `IMPLEMENTATION_ROADMAP.md`
- command-specific docs under `docs/` when that directory exists
- comment-based help in the command script when Linux deltas changed

## Roadmap Update Contract

Apply the repository roadmap procedure each time:

- move item status through `Planned`, `In Progress`, `Done`, `Blocked`, or `Deferred`
- append a progress log entry with date, item ID, files changed, scope summary, deltas, and follow-up work
- update phase notes or sprint order if implementation changed the plan

## Documentation Rules

- Keep README aligned with the actual repo structure, not the aspirational structure.
- Do not mark a command complete if tests or docs are still missing.
- For conflict-name commands, show explicit script-path invocation examples.
- Call out meaningful Linux-vs-Windows differences clearly and briefly.

## Completion Checklist

A task is only ready to close when implementation, tests, docs, and roadmap status all agree.
