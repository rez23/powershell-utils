<#
.SYNOPSIS
Gets preferred local IP addresses.

.DESCRIPTION
Returns IP addresses from Get-NetIPAddress where AddressState is Preferred
and ValidLifetime is less than 24 hours, matching your profile function logic.

.EXAMPLE
./Get-MyIp.ps1

Outputs matching local IP addresses.
#>

[CmdletBinding()]
param ()

(Get-NetIPAddress |
    Where-Object {
        $_.AddressState -eq 'Preferred' -and $_.ValidLifetime -lt '24:00:00'
    }).IPAddress
