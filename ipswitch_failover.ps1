<#
The Puporse of This script is to do a health check on the SFTP Server,
if SFTP server fails to ping out. Failover to the Secondary SFTP Server.
#>

$smtpServer = <SMTP SERVER IP ADDRESS>
$smtpFrom = "support@<COMPANY>.com"
$smtpTo = "administrator@<COMPANY>.com"
$IPSWITCH_Web = "Ipswitch WS_FTP Web Server" # WebTransfer Module
$IPSWITCH_FTP = "Ipswitch WS_FTP Server" # SFTP Module
$pingfail = 0 #Ping Fail Count

# Ping SFTP SERVER

DO
{
Write-Host $pingfail
$ping = Test-Connection <IP ADDRESS OF SFTP> -Quiet # Delay of 5 seconds between pings
if($ping -eq $False) # If Test-Connection returns a Fail
{
$pingfail++ # Increment the Count by 1.
Write-Host $pingfail
}# exit if Statment
}# exit Do-while
Until($pingfail -eq 5 ) # If ping fails 5 times exit Loop

Get-Service -DisplayName $IPSWITCH_Web | Start-Service # Start WebTransfer Module.
Get-Service -DisplayName $IPSWITCH_FTP | Start-Service # Start SFTP Module.

# Check if Services Are Started on HOSTNAME and Send Email to Support

$service = $IPSWITCH_Web
$service1 = $IPSWITCH_FTP

if(($service.status -ne "Running") -and ($service1.status -ne "Running"))
{
# Sending Email..
$smtpSubject = SFTP Server
$smtpbody = "<html>
<body>
SFTP SERVER <IP ADDRESS> has gone OFF-Line,
Service $service and $service1 are now running on Server <IP ADDRESS><br>
<p>Thanks,<p>
</p>
</body>
</html>" # End of Email Body

Send-MailMessage -SmtpServer $smtpServer -from $smtpFrom -to $smtpTo -Subject $smtpSubject -Body $smtpbody -BodyAsHtml -Priority High
}else{

# Sending Email..
$smtpSubject = SFTP SERVER
$smtpbody = "<html>
<body>
SFTP SERVER <IP ADDRESS> has gone OFF-Line,
Service $service and $service1 are not running<br>
<p>Please Start these Services.
<p>Thanks,<p>
</p>
</body>
</html>" #End of Email Body
Send-MailMessage -SmtpServer $smtpServer -from $smtpFrom -to $smtpTo -Subject $smtpSubject -Body $smtpbody -BodyAsHtml -Priority High
} # END PowerShell Script.
