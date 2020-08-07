#User Variables
$user = ${env:user}
$pswd = ${env:pass}
$vCenter_Servers = ${env:pass}

#Remove Old CSV File
$fileToCheck = "C:\Scripts\myvm.csv"
if (Test-Path $fileToCheck -PathType Leaf)
{
    Remove-Item $fileToCheck
}

$srv = Connect-VIServer -Server $vCenter_Servers -User $user -Password $pswd
$report = @()
$vCenter_Hostname = $vCenter_Servers

foreach($vm in Get-View -ViewType Virtualmachine){
    $vms = "" | Select-Object VMName, Hostname, IPAddress, OS,VMState, TotalCPU,TotalMemory,CBT
    $vms.VMName = $vm.Name 
    $vms | add-member -MemberType NoteProperty -name 'vCenter' -Value $vCenter_Hostname
    $vms.Hostname = $vm.guest.hostname
    $vms.IPAddress = $vm.guest.ipAddress
    $vms.OS = $vm.Config.GuestFullName
    $vms.VMState = $vm.summary.runtime.powerState
    $vms.TotalCPU = $vm.summary.config.numcpu
    $vms.TotalMemory = $vm.summary.config.memorysizemb
    $vms.CBT = $vm.Config.ChangeTrackingEnabled
    $report += $vms
}

$FileCSV = 'C:\Scripts\myvm.csv'
$report | Export-Csv $FileCSV -NoTypeInformation -append
