Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core

#Connection Details
$connection=${env:connectionView}
$machineName=${env:machine}
$username = ${env:user}
$password = ${env:pass}
$requester=${env:requester}


$hvserver1= Connect-HVServer -Server $connection -User $username  -Password $password
$Services1= $hvServer1.ExtensionData


Do{
$VM = Get-HVMachineSummary -MachineName $machineName | select -ExpandProperty Base | select BasicState
$Status = $VM.BasicState
Sleep -s 60

if($Status -eq 'AVAILABLE') {

} # End If 
else
{

}#End Else

}until($Status -eq 'AVAILABLE')
