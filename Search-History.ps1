<#
.SYNOPSIS
Searches PowerShell command history.

.DESCRIPTION
Reads the PSReadLine history file and filters lines containing the provided
text pattern.

.PARAMETER Pattern
Text to search inside command history.

.EXAMPLE
./Search-History.ps1 -Pattern "git"

Lists history entries that contain "git".
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [Alias('Pettern')]
    [string]$Pattern = ''
)

Get-Content (Get-PSReadLineOption).HistorySavePath |
    Where-Object { $_ -like "*${Pattern}*" }
