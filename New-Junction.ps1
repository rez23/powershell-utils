<#
.SYNOPSIS
Creates a directory junction.

.DESCRIPTION
Wraps New-Item -ItemType Junction to create a junction at -Path that points
to -Value. Extra arguments are passed through to New-Item.

.PARAMETER Value
Target directory path that the junction points to.

.PARAMETER Path
Junction path to create.

.PARAMETER Arguments
Additional arguments forwarded to New-Item.

.EXAMPLE
./New-Junction.ps1 -Value "C:\Projects\Shared" -Path "D:\LinkToShared"

Creates D:\LinkToShared as a junction to C:\Projects\Shared.
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

New-Item -ItemType Junction -Path $Path -Value $Value @Arguments
