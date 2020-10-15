#Import Hoizon View Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

#Read Text File to Array
$array = Get-Content -Path @("C:\Scripts\vdiview.txt")

#Hoizon Variables
$user = ${env:user}
$pswd = ${env:pass}


#STMP Details
$SMTPServer = 
$EMAILRECIPIANT = 
$cc = 
$From = 
$Subject = 'VDESK In maintenance Mode'


$vmwarray = @()
$vmwarraynotinarray = @()

#Looping Over Array of View Servers
foreach($item in $array){ 

$item

#Connect To view Connector
$hvServer1 = Connect-HVServer -Server $item -User $user -Password $pswd
$Services1= $hvServer1.ExtensionData

#Get Machine Summary
$vms = get-hvmachinesummary

#Loop Over Machines within HorizonView
foreach ($vm in $vms) {

#Getting Desktop-pool-Name
$VirtualMachineDeskTopPool = $vm.Base.DesktopName
#Getting Machine Name
$VirtualMachineName = $vm.Base.Name
#Getting Status of the Machine
$VirtualMachinestate = $vm.Base.BasicState
#Getting Machine Assigned User
$VirtualMachineUser = $vm.NamesData.UserName


#If Statement for Machines in Maintenance Mode
if(!$VirtualMachineUser -And $VirtualMachinestate -eq 'MAINTENANCE'){

#No User Assigned to Desktop: Delete This Machine
Remove-HVMachine -MachineNames $VirtualMachineName -DeleteFromDisk:$true -Confirm:$false
}

#vDesk has an Assigned User 
ElseIf($VirtualMachineUser -And $VirtualMachinestate -eq 'MAINTENANCE'){

$SMTPMessage = @{
To = $EMAILRECIPIANT
From = $From
Cc = $cc
Subject = $Subject
Smtpserver = $SMTPServer
}

$SMTPBODY = 
@"



"@

Send-MailMessage @SMTPMessage -Body $SMTPBody
}#Ending Elseif 
}
  Disconnect-HVServer -Server $array -Confirm:$false 
} # Ending Foreach



