# Coding Conventions

This file is the repository-root source of truth for implementation conventions.
The copy under `docs/` exists for reader convenience and should stay aligned with this file.

## Script Structure

Every script in `cmds/` must include:

```powershell
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(...)
```

With full comment-based help:

- `.SYNOPSIS` - Linux command being emulated
- `.DESCRIPTION` - behavioral differences from Linux, if any
- `.EXAMPLE` - usage compared to Linux syntax

## Naming

- Script filenames match the Linux command exactly: `touch.ps1`, `grep.ps1`, `tail.ps1`
- Parameters follow Linux flag names where possible: `-n`, `-r`, `-f`
- Provide PowerShell-friendly aliases only as secondary affordances

## Output

| Channel | Method |
|---|---|
| stdout | `Write-Output` |
| stderr | `Write-Error` or `Write-Warning` |
| never | `Write-Host` |

Exit codes follow Linux convention: `0` success, `1` general error, `2` bad usage.

## Error Handling

```powershell
$ErrorActionPreference = 'Stop'

try {
    # implementation
}
catch {
    Write-Error "command: $($_.Exception.Message)"
    exit 1
}
```

Error message format: `command: reason`

## Path Handling

- Always use `Join-Path`, `Resolve-Path`, `Convert-Path`, or `[System.IO.Path]`
- Never hardcode `\` or `/` when a path API is appropriate
- Normalize input before use when behavior depends on a resolved target

## Linux Behavioral Delta

Document known differences in `.DESCRIPTION` for each command:

| Concern | Linux | PowerShell |
|---|---|---|
| Encoding | UTF-8 | Windows PowerShell 5.1 requires explicit encoding choices |
| Line ending | LF | PowerShell often defaults to CRLF |
| Permissions | `chmod` / `chown` | No direct NTFS equivalent; stub or map intentionally |
