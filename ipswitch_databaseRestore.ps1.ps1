<# 
Restore Ipswitch WS_FTP Server to the Secondary SQL Server.
#>
Set-ExecutionPolicy RemoteSigned

$smtpServer = #SMTP SERVER IP 
$smtpFrom =  # FROM EMAIL
$smtpTo =  # TO EMAIL

# Set SQL Server instance name
$sqlName= #DATABASE Server
$timestamp = Get-Date -Format yyyy-MM-dd; #Get-Todays Date.
Import-Module SQLPS -DisableNameChecking
$dbname= #Database Name
$sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $sqlName

$DBObject = $sqlServer.Databases[$dbname] # Drop Old Table before Restoring updated Databse Tables 

# Check database Exists on Server
if($DBObject)
{
$sqlServer.KillDatabase($dbname) # Kill DATABASE 
Write-Host "...SQL Database"$dbname" Dropped Successfullyy..."
}

$backupPath= "<FILEPATH>\ws_ftp_server_$timestamp.bak"
# Create SMo Restore object instance
$dbRestore = new-object ("Microsoft.SqlServer.Management.Smo.Restore")
# Set database and backup file path
$dbRestore.Database = $dbname
$dbRestore.Devices.AddDevice($backupPath, "File")

# Set the databse file location
$dbRestoreFile = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreLog = new-object("Microsoft.SqlServer.Management.Smo.RelocateFile")
$dbRestoreFile.LogicalFileName = $dbname
$dbRestoreFile.PhysicalFileName = $sqlServer.Information.MasterDBPath + "\" + $dbRestore.Database + "_Data.mdf"
$dbRestoreLog.LogicalFileName = $dbname + "_Log"
$dbRestoreLog.PhysicalFileName = $sqlServer.Information.MasterDBLogPath + "\" + $dbRestore.Database + "_Log.ldf"
$dbRestore.RelocateFiles.Add($dbRestoreFile)
$dbRestore.RelocateFiles.Add($dbRestoreLog)

# Call the SqlRestore mathod to complete restore database 
$dbRestore.SqlRestore($sqlServer)

Write-Host "...SQL Database"$dbname" Restored Successfullyy..."


# Check database was Restored on Server and Send Email to Support

if($sqlServer.Database[$DBObject] != $null ){
# Sending Email.. 
$smtpSubject = "STFP Database restore"
$smtpbody = "<html>
<body>
<p>Database Table WS_FTP_SERVER has been successfully Restored
<p>file name ws_ftp_server_$timestamp.bak<br>
<p>Thanks,<p>
VGTSI-Support<br>
</p>
</body>
</html>" #End of Email Body
Send-MailMessage -SmtpServer $smtpServer -from $smtpFrom -to $smtpTo -Subject $smtpSubject -Body $smtpbody -BodyAsHtml -Priority High
}else{
# Sending Email.. 
$smtpSubject = "STFP Database restore"
$smtpbody = "<html>
<body>
<p>Database Table WS_FTP_SERVER has not been successfully Restored
<p>file name ws_ftp_server_$timestamp.bak<br>
<p>Thanks,<p>
VGTSI-Support<br>
</p>
</body>
</html>" #End of Email Body
Send-MailMessage -SmtpServer $smtpServer -from $smtpFrom -to $smtpTo -Subject $smtpSubject -Body $smtpbody -BodyAsHtml -Priority High
}