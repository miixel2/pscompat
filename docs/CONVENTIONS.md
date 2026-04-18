# Coding Conventions

## Script Structure

Every script in `cmds/` must include:

```powershell
#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(...)
```

With full comment-based help:
- `.SYNOPSIS` — Linux command being emulated
- `.DESCRIPTION` — behavioral differences from Linux, if any
- `.EXAMPLE` — usage compared to Linux syntax

## Naming

- Script filenames match the Linux command exactly: `touch.ps1`, `grep.ps1`, `tail.ps1`
- Parameters follow Linux flag names where possible: `-n`, `-r`, `-f`
- Provide PowerShell-friendly aliases: `-Lines` for `-n`, `-Recursive` for `-r`

## Output

| Channel | Method |
|---------|--------|
| stdout  | `Write-Output` |
| stderr  | `Write-Error` / `Write-Warning` |
| never   | `Write-Host` |

Exit codes follow Linux convention: `0` success, `1` general error, `2` bad usage.

## Error Handling

```powershell
$ErrorActionPreference = 'Stop'
try {
    # external call
} catch {
    Write-Error "command: $($_.Exception.Message)"
    exit 1
}
```

Error message format: `"<command>: <reason>"` — e.g. `"tail: file not found"`

## Path Handling

- Always use `Join-Path` and `[System.IO.Path]`
- Never hardcode `\` or `/`
- Normalize input with `Resolve-Path` or `Convert-Path` before use

## Linux Behavioral Delta

Document known differences in `.DESCRIPTION` for each command:

| Concern | Linux | PowerShell |
|---------|-------|------------|
| Encoding | UTF-8 | Windows-1252 (PS 5.1) → use `-Encoding UTF8` |
| Line ending | LF | CRLF → use `` `n `` or `[Environment]::NewLine` |
| Permissions | chmod/chown | No equivalent on NTFS → stub or map to ACL |
