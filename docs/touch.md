# touch

`touch.ps1` is the first non-conflict command implemented in `pscompat`.

## Supported Scope

- create a file when it does not exist
- update `LastAccessTime` and `LastWriteTime` when the path already exists
- process multiple paths in one invocation
- support `-c`, `--no-create`, and `-NoCreate`
- return Linux-style baseline exit codes:
  - `0` for success
  - `1` when any target fails at runtime
  - `2` for invalid usage

## Usage

```powershell
.\cmds\touch.ps1 .\notes.txt
.\cmds\touch.ps1 .\a.txt .\b.txt
.\cmds\touch.ps1 -c .\already-known.txt
.\cmds\touch.ps1 --no-create .\already-known.txt
.\cmds\touch.ps1 -NoCreate .\already-known.txt
```

Because `touch` is not a PowerShell conflict-name command in this repository, bare invocation is acceptable once `cmds\` is on `PATH`.

## Linux Compatibility Notes

- Implemented behavior matches the common Linux default flow of creating a missing file or updating timestamps on an existing path.
- `-c`, `--no-create`, and `-NoCreate` skip missing files instead of creating them.
- When any target fails, the command continues processing remaining paths and exits non-zero.

## Deferred Scope

The following Linux `touch` features are intentionally deferred for a later iteration:

- `-a` and `-m`
- `-d`, `-t`, and `-r`
- `-h`
- exact GNU error wording and timestamp precision parity
