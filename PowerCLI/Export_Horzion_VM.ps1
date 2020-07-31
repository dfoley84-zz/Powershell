#Import Modules
Import-Module VMware.VimAutomation.HorizonView
Import-Module VMware.VimAutomation.Core
Get-Module -ListAvailable 'VMware.Hv.Helper' | Import-Module

#Hoizon Variables
$user = ${env:user}
$pswd = ${env:pass}


$array = Get-Content -Path @("C:\Scripts\HorizonServers.txt")

foreach($item in $array){ 
#Connection to viewServer
$hvServer1 = Connect-HVServer -Server $item -User $user -Password $pswd
$Services1= $hvServer1.ExtensionData
$vms = Get-HVMachineSummary
$results = @()

foreach($vm in $vms){
    $MachineUser = $vm.NamesData.UserName

if(!$MachineUser){
}else{
$User = $MachineUser.split("\\")[1]

     $properties = @{
     HoizonServer = $item
     UserName = $user
     DomainUser = $vm.NamesData.UserName
     MachineName = $vm.Base.Name
     MachineFQDN = $vm.Base.DnsName
     VDIPool = $vm.NamesData.DesktopName
     MachineStatus = $vm.Base.BasicState
}

$results += New-Object psobject -Property $properties
}

}#closing $vm in $vms

} #Closing $items in $array
$results | export-csv -NoTypeInformation -path c:\Scripts\HorizonData.csv
