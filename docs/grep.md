# grep

`grep.ps1` searches files or stdin-like pipeline input with regular expressions.

## Supported Scope

- regex pattern search
- file input
- stdin / pipeline input when no file path is supplied
- multi-file filename prefixes
- `-i` for case-insensitive matching
- `-n` for line numbers
- `-v` for inverted matching
- Linux-style grep exit codes:
  - `0` when at least one selected line is found
  - `1` when no selected lines are found
  - `2` for invalid usage, invalid regex, or runtime read errors

## Usage

```powershell
.\cmds\grep.ps1 ERROR .\app.log
.\cmds\grep.ps1 -i error .\app.log
.\cmds\grep.ps1 -n ERROR .\app.log
.\cmds\grep.ps1 -v DEBUG .\app.log
Get-Content .\app.log | .\cmds\grep.ps1 ERROR
```

Because `grep` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- Pattern syntax follows .NET regular expressions, which is close enough for common usage but not identical to GNU grep.
- When multiple files are supplied, selected lines are prefixed with `file:`.
- With `-n`, selected lines are prefixed with one-based line numbers.

## Deferred Scope

The following Linux `grep` features are intentionally deferred for a later iteration:

- recursive mode (`-r`)
- fixed-string mode (`-F`)
- count mode (`-c`)
- quiet mode (`-q`)
- binary file handling
