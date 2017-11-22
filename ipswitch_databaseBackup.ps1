<# 
Backing up SQL Ipswitch WSFTP Server
#>

## Full + Log Backup of MS SQL Server databases/span>            
## with SMO.            
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.ConnectionInfo');            
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Management.Sdk.Sfc');            
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO');            
# Required for SQL Server 2008 (SMO 10.0).            
[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended');            
$Server = "(local)";     # SQL Server Instance.            
$Dest = "C:\test\";    # Backup path on server (optional).            
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server $Server;
$dbname = # Database Name
# If missing set default backup directory.            
If ($Dest -eq "")            
{ $Dest = $server.Settings.BackupDirectory + "\" };            
Write-Output ("Started at: " + (Get-Date -format yyyy-MM-dd));            
# Full-backup for every database            
        $timestamp = Get-Date -format yyyy-MM-dd;            
        $backup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup");            
        $backup.Action = "Database";            
        $backup.Database = $dbname           
        $backup.Devices.AddDevice($Dest + $dbname + "_" + $timestamp + ".bak", "File");            
        $backup.BackupSetDescription = "Full backup of " +$dbname + " " + $timestamp;            
        $backup.Incremental = 0;            
        # Starting full backup process.            
        $backup.SqlBackup($srv);
Write-Output ("Finished at: " + (Get-Date -format  yyyy-MM-dd));