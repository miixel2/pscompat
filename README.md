# pscompat

Native PowerShell implementations of familiar Linux shell commands.
No WSL. No Cygwin. No external binaries. Just PowerShell.

---

## Goal

Bring Linux CLI behavior to Windows with stable output shape, exit codes, and pipeline semantics using native PowerShell implementations that stay compatible with Windows PowerShell 5.1 first.

---

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+
- No external runtime dependencies

---

## Current Status

Repository scaffolding is in place for implementation work:

- `cmds/` exists for command scripts
- `lib/` contains shared helper primitives
- `tests/` contains shared test helpers
- `config/` exists as the reserved home for config templates

The first user-facing command is now implemented: `touch.ps1`.

---

## Usage

### Non-conflict commands

Once a non-conflict command is implemented and `cmds\` is on `PATH`, bare command invocation is acceptable.

### Conflict-name commands

Some Linux command names collide with PowerShell aliases, functions, or Windows executables.
Until a dedicated resolution strategy exists, invoke those commands by explicit script path:

```powershell
.\cmds\tee.ps1 -Path .\out.txt
```

Do not assume that adding `cmds\` to `PATH` will make `tee`, `sort`, `cat`, or other conflict names resolve to `pscompat`.

---

## Commands

| Command | Status | Linux Equivalent | Notes |
|---|---|---|---|
| `touch` | done | `touch` | Create file, update timestamps, supports `-c` |
| `head` | done | `head` | First lines from file or stdin, supports `-n` |
| `tail` | planned | `tail` | Output last N lines of file |
| `wc` | planned | `wc` | Word, line, and byte counts |
| `which` | planned | `which` | Locate a command in `PATH` |
| `grep` | planned | `grep` | Search text with regex |
| `tee` | planned | `tee` | Conflict-name command; explicit script path required |

Status legend: `done`, `planned`, `partial`

---

## Project Structure

```text
pscompat/
|-- cmds/                # One .ps1 per Linux command
|-- config/              # Reserved home for config templates
|-- docs/                # Per-command docs and reader-friendly mirrors
|-- lib/                 # Shared helpers
|-- tests/               # Pester tests and shared test helpers
|-- .ai/skills/          # Project-local implementation playbooks
|-- ADDING_COMMANDS.md   # Root workflow reference
|-- CONVENTIONS.md       # Root coding and behavior reference
|-- IMPLEMENTATION_ROADMAP.md
`-- README.md
```

---

## Development

### Adding a new command

See [ADDING_COMMANDS.md](ADDING_COMMANDS.md) for the command workflow and [IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md) for sequencing.

### Conventions

See [CONVENTIONS.md](CONVENTIONS.md) for output, exit code, path handling, and compatibility rules.

### Running tests

```powershell
Invoke-Pester .\tests\ -Output Detailed
```

### Implemented command docs

- [head](docs/head.md)
- [touch](docs/touch.md)

---

## Known Behavioral Differences

| Concern | Linux | PowerShell 5.1 |
|---|---|---|
| Default encoding | UTF-8 | Requires explicit encoding choices |
| Line ending | LF | Often defaults to CRLF |
| Permissions | `chmod` / `chown` | Must be documented or mapped intentionally |

---

## License

MIT
