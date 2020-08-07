#Import Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module
Get-Module -ListAvailable 'VMware.Hv.QueryServiceService' | Import-Module
Get-Module -ListAvailable 'VMware.Hv.QueryDefinition' | Import-Module

#Hoizon Variables
$user = ${env:user}
$pswd = ${env:pass}
$connection = ${env:connnection_server}
$virtualMachine = ${env:VMName}
$AssignedUser = ${env:user}
$DesktopPool = ${env:Desktoppool}

#Connect to the Horizon Server
$hvserver1 = Connect-HVServer -server $connection
$Services1 = $hvserver1.ExtensionData

#Place Machine into Maintenance Mode
Set-HVMachine -MachineName $virtualMachine -Maintenance:ENTER_MAINTENANCE_MODE

#Remove AssignedUser
$machineservice = New-Object vmware.hv.machineservice
$machineid = (Get-HVMachine -MachineName $virtualMachine).id
$MachineInfo = $machineservice.read($Services1, $machineid)
$MachineInfo.getbasehelper().setuser($null)
$machineservice.update($Services1, $MachineInfo)

#Not Need Remove User from Pool Entitlment.
#Remove-HVEntitlement -ResourceName $DesktopPool -User $AssignedUser -ResourceType Desktop -Type User

Disconnect-HVServer -Server $connection -Force -Confirm:$false


