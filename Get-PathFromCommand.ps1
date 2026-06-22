<#
.SYNOPSIS
Shows the resolved executable/script path for a command.

.DESCRIPTION
Uses Get-Command to locate a command and outputs its Path property.
This is a simple PowerShell equivalent of where/which behavior.

.PARAMETER Cmd
Command name to resolve.

.EXAMPLE
./whereis.ps1 pwsh

Outputs the path of the pwsh executable.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [Alias('Command')]
    [string]$Cmd
)

$commandInfo = Get-Command -Name $Cmd -ErrorAction Stop
$commandInfo.Path
