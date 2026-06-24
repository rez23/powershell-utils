<#
.SYNOPSIS
Get information about virtual machines.

.DESCRIPTION
Returns information about virtual machines, including their state, CPU usage, memory usage, uptime, and network interfaces.

.PARAMETER Name
Specify the name of the virtual machine to retrieve information for.

.PARAMETER Interfaces
Include network interface information in the results.

.PARAMETER All
Include all available information in the results.

.PARAMETER IpAddresses
Include IP address information in the results.

.PARAMETER InterfacesNames
Include network interface names in the results.

.EXAMPLE
./Get-VirtualMachineInfo.ps1 -Name "MyVM"
#>
[CmdletBinding()]
param(
    [parameter(Mandatory = $false)]
    [string]$Name,
    [parameter(Mandatory = $false)]
    [switch]$Interfaces,
    [parameter(Mandatory = $false)]
    [switch]$All,
    [parameter(Mandatory = $false)]
    [switch]$IpAddresses,
    [parameter(Mandatory = $false)]
    [switch]$InterfacesNames
)

function Get-Ipvb4AddressesFromVm {}

function Get-VirtualMachineInfo {
    if ($Name) {
        return Get-VM -Name $Name
    }
    else {
        return Get-VM
    }
}

function Get-IpFromNetworkAdapters {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)][object[]]$InputArray,
        [Parameter(Mandatory = $false)][switch]$IPv4
    )
    
    $InputArray = $InputArray.IPAddresses -split "\n"
    $out = @()
    for ($i = 0; $i -lt $InputArray.Count; $i += 1) {
        if ($i % 2 -eq 0) {
            $a = $InputArray[$i]
            $b = $InputArray[$i + 1]
            if ($IPv4) {
                $out += $a
            } else {
                $out += "{ipv4: $a, ipv6: $b}"
            }
        }
    }

    return $out
}

# Define default properties to show if no selection is made
$DefaultPropsToShow = @("Name", "State", "CPUUsage", "MemoryAssigned", "Uptime", "IPAddresses")

# get user selection for which props to show
$SelectedProps = $PSBoundParameters['Get']
    
# and get the vm info list (based on VmName)
$VmList = Get-VirtualMachineInfo
    
# add default props to selection if not already included
$DefaultPropsToShow | Where-Object { $_ -notin $SelectedProps } | ForEach-Object {
    $SelectedProps += $_
}


if ($All) {
    return $VmList | Select-Object -Property *
}

if ($Interfaces) {
    $adapters = $VmList.NetworkAdapters | Select-Object -Property Name, SwitchName, MacAddress, Status, IPAddresses
    return ($adapters | Select-Object -Property *)
}

if ($IpAddresses) {
    $MachineIpAddresses = $VmList.NetworkAdapters

    return ($MachineIpAddresses | Select-Object -Property VMName, SwitchName, IPAddresses )
}

# Get the network adapters and add IPAddresses property to the VM info
return $vmList | Select-Object -Property name, state, cpuusage, memoryassigned, uptime, @{Name = "IpV4"; Expression = { $VmList.NetworkAdapters.IPAddresses -split "\n"| ForEach-Object -Begin {$i=0} -Process { if (($i%2) -eq 0) {$_} $i++} } }