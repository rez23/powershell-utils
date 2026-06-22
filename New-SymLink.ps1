<#
.SYNOPSIS
Creates a symbolic link.

.DESCRIPTION
Wraps New-Item -ItemType SymbolicLink to create a symlink at -Path that points
to -Value. Extra arguments are passed through to New-Item.

.PARAMETER Value
Target path that the symbolic link points to.

.PARAMETER Path
Symbolic link path to create.

.PARAMETER Arguments
Additional arguments forwarded to New-Item.

.EXAMPLE
./New-SymLink.ps1 -Value "C:\Tools" -Path "D:\ToolLink"

Creates D:\ToolLink as a symbolic link to C:\Tools.
#>

[CmdletBinding()]
[OutputType([System.IO.FileSystemInfo])]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Value,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$Path,

    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Arguments = @()
)

New-Item -ItemType SymbolicLink -Path $Path -Value $Value @Arguments
    