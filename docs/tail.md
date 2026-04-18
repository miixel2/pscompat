# tail

`tail.ps1` provides the last-lines counterpart to `head.ps1`.

## Supported Scope

- default output of the last 10 lines
- explicit line selection with `-n`
- file input
- stdin / pipeline input when no file path is supplied
- multiple file input with Linux-style section headers
- baseline exit codes:
  - `0` for success
  - `1` for runtime read errors
  - `2` for invalid usage

## Usage

```powershell
.\cmds\tail.ps1 .\app.log
.\cmds\tail.ps1 -n 5 .\app.log
Get-Content .\app.log | .\cmds\tail.ps1 -n 5
.\cmds\tail.ps1 -n 3 .\a.txt .\b.txt
```

Because `tail` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- When more than one file is supplied, the command prints `==> <file> <==` headers and a blank line between sections.
- Missing files produce a non-zero exit code after processing the remaining paths.
- If no file path is supplied, the command reads from stdin-like pipeline input.
- `-n 0` succeeds and emits no lines.

## Deferred Scope

The following Linux `tail` features are intentionally deferred for a later iteration:

- `-f` follow mode
- `-c` byte mode
- relative line forms such as `-n +5`
