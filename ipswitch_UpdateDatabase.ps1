<#
Once Database has being Restored, update HOSTNAME_NAME and IP Address & FTP Listner 
for the secondary SFTP Server. 
#>

PARAM ()
BEGIN{

#Global Variables
$smtpServer=  #SMTP SERVER
$from= #Email From
$testing="Disabled"#Disabled to Email Users
$testRecipient=#Testing Email
$support=#Email VGTSI Support 
$date = Get-Date -format MMddyyyy # Get Date 

    # modify these to point to your db server and database
    $SqlServer =  #DB Server
    $SqlDBName =  #Database being Connected to
    # use these for a sql login.  Or you can modify the connection string to use integrated authentication and set the scheduled task to run under that user context (omit User ID and Password from the connect string).
    $SqlLoginUser = #Username
    $SqlLoginPassword = #Password 

    #Database Connection and Query
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SqlServer;Database=$SqlDBName;Integrated Security=SSPI;Persist Security Info=False;User ID=$SqlLoginUser;Password=$SqlLoginPassword"
    $SqlQuery="UPDATE dbo.FTP_Listeners
				 SET IP_Address=''
				 WHERE IP_Address=';
				
                 UPDATE dbo.Hosts
				 SET Host_Name='SECONDARY.local.com', Top_Dir='C:\Program Files (x86)\Ipswitch\WS_FTP Server\SECONDARY.local.com'
				 WHERE Host_Name='PRIMARY.local.com';"

    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    [void] $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close() # Close Connection to DB
}
END{}

