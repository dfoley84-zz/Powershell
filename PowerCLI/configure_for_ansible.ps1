Set-PowerCLIConfiguration -InvalidCertificateAction:Ignore -ParticipateInCeip $false -Confirm:$false
$vCenterCreds = Import-clixml -path 
$localAdminCreds = Import-clixml -path 

$vCenter = $args[0]
$virtualMachine = $args[1]

Connect-VIServer -Server $vCenter -Credential $vCenterCreds

$vm = Get-vm -name $virtualMachine

$downloadAnsibleScript = "wget https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1 -OutFile C:\Windows\Temp\ConfigureRemotingForAnsible.ps1"
$configureWinRM = "C:\Windows\Temp\ConfigureRemotingForAnsible.ps1 -EnableCredSSP -DisableBasicAuth -Verbose"

Invoke-VMScript -VM $vm -GuestCredential $localAdminCreds -ScriptType Powershell -ScriptText $downloadAnsibleScript
Invoke-VMScript -VM $vm -GuestCredential $localAdminCreds -ScriptType Powershell -ScriptText $configureWinRM
Disconnect-VIServer -Server $vCenter -Confirm:$false
