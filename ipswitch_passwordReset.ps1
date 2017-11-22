<#
This Script queries the IPswitch WS_FTP SQL Database
'MATH' function is used to calcuate Days remaining,
Any user that has a password set to expire within 2 das will recive an email with
a new password 
#>

PARAM ()
BEGIN{

#Generate Password for SFTP Reset

function Get-RandomPassword 
{
	param(
		$length = 15,
		$characters ='abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ123456789!"§$%&/()=?*+#_'
	)
	# select random characters
	$random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
	# output random pwd
	$private:ofs=""
	[String]$characters[$random]
}
function Randomize-Text 
{
	param(
		$text
	)
	$anzahl = $text.length
	$indizes = Get-Random -InputObject (0..$anzahl) -Count $anzahl
	
	$private:ofs=''
	[String]$text[$indizes]
}

function Get-ComplexPassword {
    $password  = Get-RandomPassword -length 4 -characters 'ABCDEFGHKLMNPRSTUVWXYZ'
    $password  += Get-RandomPassword -length 3 -characters 'abcdefghiklmnprstuvwxyz'
	$password += Get-RandomPassword -length 4 -characters '}$?!=_/+-*{'
	$password += Get-RandomPassword -length 3 -characters '1234567890'

	Randomize-Text $password
} # End Password Function

#Global Variables
$smtpServer=  # SMTP SERVER IP Address 
$from= # Email From
$logging="Disabled" # If Set to Enable Logging will be On Set to Disabled to Disable Logging
$logFile =  # Path to Log File. ie. G:\mylog.csv
$testing="Disabled "# Disabled to Email Users
$testRecipient= # Testing Email
$support= # EmailSupport 
$date = Get-Date -format MMddyyyy # Get Date 
$MaxPasswordAge = 42 # Max Password Age for SFTP Users



# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File
        Add-Content $logfile "Date, Name, User Id, Email Address, Days to Expire, Last Logged On"
    }
} # End Logging Check

    # modify these to point to your db server and database
    $SqlServer = # Database Server
    $SqlDBName =  # Database name
    $SqlLoginUser =  # Username
    $SqlLoginPassword = # Password 

    # Database Connection and Query
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SqlServer;Database=$SqlDBName;Integrated Security=SSPI;Persist Security Info=False;User ID=$SqlLoginUser;Password=$SqlLoginPassword"
    $SqlQuery ="SELECT * FROM dbo.Host_Users 
                WHERE CONVERT(INT,GETDATE()) - CONVERT(INT,Pass_Reset_Date) >=30
                AND CONVERT(INT,GETDATE()) - CONVERT(INT,Pass_Reset_Date) <=42 
                AND Pass_Expire_Days = 42;"


    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery 
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    [void] $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close() # Close Connection to DB
    $IFTPADDU = 'C:\Program Files (x86)\Ipswitch\WS_FTP Server\iftpaddu.exe'
}
PROCESS
{
   Foreach($data in $DataSet)
   {  
    $DataSet.Tables[0]|ForEach-Object
    {
    Write-Output $_ # Write output
    $name = $_.User_FullName # Get User Full Name
    $userspassword = $_.User_Password # Getting Current Password.
    $userName = $_.User_LoginID # Get User Login Name
    $oldpassword = $_.User_Password # Getting User Password
    $emailaddress = $_.User_Email_Addr # Get Users Email Address
    $Last_Logon_Date = $_.last_logon_date # Get Users Last Logged on Date
    $days= ($_.Pass_Reset_Date - [datetime]::Today).Days + $_.Pass_Expire_Days # Getting Days Left.
    $daysleft = $days # vaildate
    $daysleft = "$days" # Add to Output
    $messageDays ="$daysleft" + " days" # getting Days 
    $newpassword = Get-ComplexPassword # Generate new Password
    }
       #[Diagnostics.Process]::Start("iftpaddu -mod -u $userName -h <> -p $newpassword +forcechgpass")

        Start-Process $IFTPADDU "iftpaddu -mod -u $userName -h <Ipswitch SFTP SERVER> -p $newpassword +forcechgpass"

       #Add-Content $filePath "iftpaddu -mod -u $userName -h <> -p $newpassword +forcechgpass" #Add To File


  #  $proc1 = Start-Process $filePath -PassThru
   # $handle = $proc1.Handle
    #$proc1.WaitForExit();

    # Sending Email to User
    $subject="SFTP Password due to expire"   # Email Subject

    # Email Body Set Here.
    $body ="<html>
    <body>
    Dear $name,
    <p>Your SFTP password was due to expire in <b><font color=red>$messageDays</b></font><br>
    <p>Your SFTP Username is :  $userName.<br>
    <p>Temporary  Account password for your Main User Account is : <b><font color=red>$newpassword</b></font><br>
    <p>Thanks,<br>
    Support<br> 
    </P>
    </body>
    </html>"  #End Email Body
     # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing
    # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$name,$userName,$emailaddress,$days,$Last_Logon_Date" 
        }
      # Send Email Message
       Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High  
       }#End 
    }#End Process
END{}# Remove-Item $filePath} 



