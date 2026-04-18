# wc

`wc.ps1` provides the first counting-oriented text utility in `pscompat`.

## Supported Scope

- default output of line, word, and byte counts
- explicit `-l`, `-w`, and `-c`
- file input
- stdin / pipeline input when no file path is supplied
- multiple file input with `total`
- baseline exit codes:
  - `0` for success
  - `1` for runtime read errors
  - `2` for invalid usage

## Usage

```powershell
.\cmds\wc.ps1 .\app.log
.\cmds\wc.ps1 -l .\app.log
.\cmds\wc.ps1 -w -c .\app.log
Get-Content .\app.log | .\cmds\wc.ps1 -l
.\cmds\wc.ps1 .\a.txt .\b.txt
```

Because `wc` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- Default output order is line count, word count, byte count, then file label.
- When more than one file is supplied, the command prints a `total` row.
- Missing files produce a non-zero exit code after processing the remaining paths.
- `-c` currently means byte count, matching Linux `wc`.

## Deferred Scope

The following Linux `wc` features are intentionally deferred for a later iteration:

- `-m` character count
- `-L` maximum line length
- closer parity for raw Unix pipe byte counting under native PowerShell pipelines
