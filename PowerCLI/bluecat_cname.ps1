#Import Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

#Connection to viewServer
$hvServer1 = Connect-HVServer -Server viewtest1 
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
#Getting FQDN for Machine
$MachineFQDN = $vm.Base.DnsName
#Getting Users
$MachineUser = $vm.NamesData.UserName


#If MachineUser Variable is Null (Do Nothing)
if (!$MachineUser) {
}
else {

#Calling Bluecat To Add CNAME for Horizon VDI Machine
$bluecatUrl = "" #BlueCat URL
$login = "" #BlueCat Login Redirect
$cname= "" #Cname URL

#User STDOUT is Domain\<user> using Split to just get the User Name
$User = $MachineUser.split("\\")[1]

$body = @{
    username   = "" 
    password   = ""
}

$head =@{
	 "Cache-Control"= "no-cache"
}

$loginUrl = $bluecatUrl + $login 

#Getting Bluecat Token
$token = irm -Method Post -UseBasicParsing -Uri $loginUrl -Headers $head -Body $body | select access_token -expa access_token
if($token){    
    $headers =@{
    "auth" = "Basic $token"
    "Content-Type"  = "application/json"
	 "Cache-Control"= "no-cache"
    }
}

#CNAME & Target:
$record = @{
    cname = ""
    target   =  $MachineFQDN
}
$record = $record | ConvertTo-Json 

## ADD A Host Record
$addRecUrl = $bluecatUrl + $cname
irm -Method Post -UseBasicParsing -Uri $addRecUrl -Headers $headers -Body $record
}

}
