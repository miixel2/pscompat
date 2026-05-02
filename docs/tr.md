# tr

`tr.ps1` translates or deletes characters from stdin-like pipeline input.

## Supported Scope

- character translation from `SET1` to `SET2`
- deletion with `-d`
- simple ascending ranges such as `a-z` and `0-9`
- common escapes:
  - `\n`
  - `\r`
  - `\t`
  - `\\`
- baseline exit codes:
  - `0` for success
  - `2` for invalid usage

## Usage

```powershell
Get-Content .\input.txt | .\cmds\tr.ps1 a-z A-Z
Get-Content .\input.txt | .\cmds\tr.ps1 -d 0-9
Get-Content .\input.txt | .\cmds\tr.ps1 \n ,
```

Because `tr` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- `tr` reads from stdin-like pipeline input. It does not accept file operands.
- When `SET2` is shorter than `SET1`, the last replacement character is reused.
- Output is written as a character stream to preserve translated newlines better than line-oriented output would.

## Deferred Scope

The following Linux `tr` features are intentionally deferred for a later iteration:

- complement mode (`-c`)
- squeeze mode (`-s`)
- character classes such as `[:lower:]`
- octal escapes
