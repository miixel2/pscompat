# pscompat

Native PowerShell implementations of Linux shell commands.  
No WSL. No Cygwin. No external binaries — just PowerShell.

---

## Goal

Bring Linux CLI behavior to Windows — output format, exit codes, and pipeline semantics — using only native PowerShell 5.1+.

---

## Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- No external dependencies

---

## Usage

### Option A — Run directly

```powershell
.\cmds\tail.ps1 -n 20 .\logs\app.log
```

### Option B — Add to PATH

Add the `cmds\` directory to your `$env:PATH` in your PowerShell profile:

```powershell
$env:PATH += ";G:\My Drive\Develop\cmd\pscompat\cmds"
```

Then use commands directly:

```powershell
tail -n 20 .\logs\app.log
grep -r "ERROR" .\logs\
```

---

## Commands

| Command | Status | Linux Equivalent | Notes |
|---------|--------|-----------------|-------|
| `touch` | 🚧 planned | `touch` | Create file or update timestamp |
| `tail`  | 🚧 planned | `tail` | Output last N lines of file |
| `grep`  | 🚧 planned | `grep` | Search text with regex |
| `wc`    | 🚧 planned | `wc` | Word/line/char count |
| `head`  | 🚧 planned | `head` | Output first N lines of file |
| `tee`   | 🚧 planned | `tee` | Read stdin, write to file and stdout |
| `which` | 🚧 planned | `which` | Locate a command in PATH |

Status: ✅ done · 🚧 planned · ⚠️ partial

---

## Project Structure

```
pscompat/
├── cmds/         # One .ps1 per Linux command
├── lib/          # Shared helper functions (dot-sourced)
├── config/       # .env.example and config templates
├── tests/        # Pester v5 test files
└── docs/         # Per-command usage and Linux behavioral reference
```

---

## Design Principles

- **Behavior-compatible** — output format and exit codes match Linux
- **Native PowerShell** — no WSL, Cygwin, Git Bash, or Unix binaries
- **Pipeline-friendly** — accepts `ValueFromPipeline` where Linux accepts stdin
- **Composable** — each script works standalone and chains in pipelines

---

## Development

### Adding a new command

See [`docs/ADDING_COMMANDS.md`](docs/ADDING_COMMANDS.md) for the full checklist, script template, and test template.

### Running tests

```powershell
# Run all tests
Invoke-Pester .\tests\ -Output Detailed

# Run single command tests
Invoke-Pester .\tests\tail.Tests.ps1 -Output Detailed
```

### Conventions

See [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md) for naming rules, output behavior, error handling, and Linux behavioral delta reference.

---

## Known Behavioral Differences

| Concern | Linux | PowerShell (5.1) |
|---------|-------|-----------------|
| Default encoding | UTF-8 | Windows-1252 → explicit `-Encoding UTF8` required |
| Line ending | LF | CRLF → normalized with `` `n `` or `[Environment]::NewLine` |
| Permissions | `chmod` / `chown` | No NTFS equivalent → stubbed or mapped to ACL |

---

## License

MIT
