#Import Hoizon View Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

$username=${env:user}
$password=${env:pass}
$requester=${env:requester}
$poolname=${env:nodepool}
$machinename=${env:machine}
$Server=${env:horizonserver}

#Connect to vCenter
$hvserver1= Connect-HVServer -Server $Server -User $username  -Password $password
$Services1= $hvServer1.ExtensionData
#Add Machine to vDesk Pool
add-hvdesktop -poolname $poolname -machines $machinename -user $requester

Start-Sleep -s 30

#Getting HVMachineSummary for newly Created Machine
$vm = Get-HVMachineSummary -MachineName $machinename

#Getting the Assigned UserName
$requesterdomainName = $vm.NamesData.UserName

#Remove User from Entitlement Group.
Remove-HVEntitlement -User $UserName -ResourceName $poolname -ResourceType Desktop -Type User

Disconnect-HVServer -Server $Server -Confirm:$false
