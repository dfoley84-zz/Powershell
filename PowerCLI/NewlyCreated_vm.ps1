#Read Text File to of vCenters to an Array
$vCenter_Servers = ''

#User Variables
$user = ${env:user}
$pswd = ${env:pass}

#Email Variables
$SMTPServer = 
$EMAILRECIPIANT = 
$From = 
$Subject = 


#Get-Date
$now = Get-Date
$start = $now.AddDays(-1)

#Arrays lists
$deploymentChains = @()
$deployedvms = @()
$newVmarray = @()
$results = @()

#Limits 
$vmCPU = 8
$vmMemory = 32



#Remove Old CSV File
$fileToCheck = "C:\Scripts\reportTEST.csv"
if (Test-Path $fileToCheck -PathType Leaf)
{
    Remove-Item $fileToCheck
}

#Looping Over Array of vSphere Servers
foreach($item in $vCenter_Servers) { 
#Connect to vCenter
$srv = Connect-VIServer -Server $item -User $user -Password $pswd
$item

  #Getting the Event For Newly Deployed Machines within
$events = Get-VIEvent -Types Info -Start $start -Finish $now -MaxSamples ([int]::MaxValue) -Server $srv 

#Searching for Events with Creating or Deployed
$deployments = $events | where {$_ -is [Vmware.vim.VmCreatedEvent]} 



#Looping Over Each Event
foreach($deployment in $deployments){
$dataObj = "" | Select-Object events
$dataObj.events = $events | Where-Object {$_.ChainID -eq $deployment.ChainID}
$deploymentChains += $dataObj
}


foreach($chain in $deploymentChains) {
#Getting Virtual Machine Name in the Events
$newVM = ($chain.events.vm.name) #Removed $chain.events[*].vm.Name due to position of Event in Some vSphere Environments

#Adding New to Array
$deployedvms += $newVM
}

#Looping Over Each VM in the Array
foreach($newvms in $deployedvms) {

$Exists = get-vm -name $newvms -ErrorAction SilentlyContinue
if ($Exists) {
        $result = "" | select vmName,NumCpu,MemoryGB
        $result.vmName = $Exists.Name 
        $result.NumCpu = $Exists.NumCpu
        $result.MemoryGB = $Exists.MemoryGB

        #Checking if the Memory or CPU is Creater then the Limit Variables 
        if($result.MemoryGB -gt $vmMemory -or $result.NumCpu -gt $vmCPU) {
            $results += $result | Where {$Exists -notcontains $_} 
         } # End If Statment

  } Else {
    Write-Host "VM Not Found"
  }
    
} #Ending foreach($newvms in $deployedvms)

$deploymentChains = @()
$deployedvms = @()
$newVmarray = @()

Disconnect-VIServer -Server $item -confirm:$false -Force

} #Ending vCenter Loop

foreach($vms in $results) {
$vms | Export-Csv -Path C:\Scripts\reportTEST.csv -NoTypeInformation -UseCulture -append
}

#Sending Email if CSV Files Exists
$fileToCheck = "C:\Scripts\reportTEST.csv"
if (Test-Path $fileToCheck -PathType Leaf)
{
$SMTPMessage = @{
To = $EMAILRECIPIANT
From = $From
Subject = $Subject
Smtpserver = $SMTPServer
}
$SMTPBODY = 
@"

"@
Send-MailMessage @SMTPMessage -Body $SMTPBody -Attachments $fileToCheck
}



