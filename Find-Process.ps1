<#
.SYNOPSIS
Finds processes by name and optionally stops them.

.DESCRIPTION
Searches running processes by name using exact or regex matching.
By default, returns matching process objects. If -Stop is specified, the script
can stop matches with optional confirmation and force mode.

.PARAMETER Pattern
Process name pattern to search.

.PARAMETER Stop
Stops matching processes instead of returning them.

.PARAMETER Force
Stops processes without confirmation and passes -Force to Stop-Process.

.PARAMETER Exact
Matches process names with exact equality instead of regex.

.EXAMPLE
./Find-Process.ps1 -Pattern "code"

Lists processes with names that match "code".

.EXAMPLE
./Find-Process.ps1 -Pattern "node" -Stop -Force

Stops matching node processes without confirmation.
#>

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [Alias('Pettern')]
    [string]$Pattern = '',

    [switch]$Stop = $false,
    [switch]$Force = $false,
    [switch]$Exact = $false
)

$processList = if ($Exact) {
    Get-Process | Where-Object Name -eq $Pattern
}
else {
    Get-Process | Where-Object Name -imatch $Pattern
}

if (-not $Stop) {
    return $processList
}

if (-not $Force) {
    $answer = Read-Host 'Do you want to stop them? (y/n)'
    if ($answer -ne 'y') {
        return
    }
    $processList | Stop-Process
    return
}

Write-Host 'Stopping the following processes:' -ForegroundColor Yellow
$processList | Stop-Process -Force
