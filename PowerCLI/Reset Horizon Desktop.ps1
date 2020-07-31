#Import Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module
Get-Module -ListAvailable 'VMware.Hv.QueryServiceService' | Import-Module
Get-Module -ListAvailable 'VMware.Hv.QueryDefinition' | Import-Module

#Hoizon Variables
$user = ${env:user}
$pswd = ${env:pass}
$connection = ${env:horizonserver}
$virtualMachine = ${env:horizonvirtaulmachine}

#Connect to the Horizon Server
$connectviewserver = Connect-HVServer -server $connection -User $user -Password $pswd
$Services1= $hvServer1.ExtensionData
Reset-HVMachine -MachineName $virtualMachine -Confirm:$false 

#Disconnect 
Disconnect-HVServer -Server $connection -Force -Confirm:$false


