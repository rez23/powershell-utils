# prepare completion for selectable props
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
    return $VmList
}

if ($Interfaces) {
    $adapters = $VmList.NetworkAdapters | Select-Object -Property Name, SwitchName, MacAddress, Status, IPAddresses
    return ($adapters | Format-Table -AutoSize)
}

if ($IpAddresses) {
    $MachineIpAddresses = $VmList.NetworkAdapters

    return ($MachineIpAddresses | Format-Table -Property SwitchName, IPAddresses -AutoSize)
}

# Get the network adapters and add IPAddresses property to the VM info
$MachineAdapters = $VmList.NetworkAdapters
$DefaultVmInfo = $VmList | Add-Member -MemberType NoteProperty -Name "IPAddresses" -Value $MachineAdapters.IPAddresses -PassThru
return $DefaultVmInfo | Format-Table -Property $DefaultPropsToShow -AutoSize
