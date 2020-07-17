#Import Hoizon View Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

#Read Text File to Array
$array = Get-Content -Path @("C:\Scripts\view.text")

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
$hvServer1 = Connect-HVServer -Server $item
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

#If Statement for Machines in Maintenance Mode
if($VirtualMachinestate -eq 'MAINTENANCE') {

#Adding VirtualMachines to Array:
$vmwarray += $VirtualMachineName

#Array To only allow one entry per VM.
$vmwarraynotinarray += $vmwarray | Where {$vmwarraynotinarray -notcontains $_}


}else{

}#End Else Statement:

#Sending Email To Users 


}# End Foreach Loop -> VM in VMs

#Sending Email For Ticket
foreach($CreateTicket in $vmwarraynotinarray) {


}

#Removing Elements From Last View Broker -> So Not to Resend Emails
$vmwarray = @()
$vmwarraynotinarray = @()

} # Ending Foreach -> item in array



