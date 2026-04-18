#Requires -Version 5.1

Set-StrictMode -Version Latest

function New-PsCompatLineBuffer {
    [CmdletBinding()]
    param()

    return New-Object 'System.Collections.Generic.List[string]'
}

function Add-PsCompatPipelineLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Buffer,

        [AllowNull()]
        [object]$InputObject
    )

    if ($null -eq $InputObject) {
        $Buffer.Add('') | Out-Null
        return
    }

    $Buffer.Add([string]$InputObject) | Out-Null
}

function Get-PsCompatBufferedLines {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$Buffer
    )

    return ,$Buffer.ToArray()
}
