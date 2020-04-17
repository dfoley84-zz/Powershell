
#vCenter Variables
$user = ''
$pswd = ''
$vCenter_Servers = ""

#Email Variables
$SMTPServer = 'smtphost..com'
$EMAILRECIPIANT = ''
$From = '.@.com'
$Subject = 'ESXi Maintance Mode'

$now = Get-Date
$start = $now.AddDays(-15)
$esxiHosts = Import-CSV C:\Scripts\Report1.csv #Reading CSV File
$PSEmailServer = 'smtphost..com'

$MaitanceMode = @()
$Ticket = @()


foreach($ESXI in $esxiHosts){

 $Ticket += $ESXI | Select-Object -ExpandProperty Name
}

foreach($vCenter in $vCenter_Servers) {

$srv = Connect-VIServer -Server $vCenter -User $user -Password $pswd
Get-VMHost -PipelineVariable esx -Server $srv |  Where-Object {$_.ConnectionState -eq 'Maintenance'} |


ForEach-Object -Process {

    $maintEntered = Get-VIEvent -Entity $esx -Start $start -MaxSamples ([int]::MaxValue) -Server $srv |

         Where-Object{$_ -is [VMware.Vim.EnteredMaintenanceModeEvent]}

    if($maintEntered){  
     #Skipping
    }
    else {

         $MaitanceMode += $esx | Select-Object -ExpandProperty Name

         }
   }
} #Ending ForEach Loop

$NoTicket = $MaitanceMode | Where {$Ticket -notcontains $_}

'''
#Create Service Now Ticket.. 
foreach($ServiceNow in $NoTicket){
}
'''

$SMTPMessage = @{
To = $EMAILRECIPIANT
From = $From
Subject = $Subject
Smtpserver = $SMTPServer
}

$SMTPBODY = 
@"
The Following ESXI Hosts Are Now in MaitanceMode for Over 15Days: 
$NoTicket + "`n"
"@

Send-MailMessage @SMTPMessage -Body $SMTPBody
