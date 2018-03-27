<#
This Script makes a call to the IPswitch WS_FTP SQL Database
Checks the last date a users account password was change, 'MATH' function is used 
to calcuate number of days Remaining till password expires,
Email is sent out to users.
#>

PARAM ()
BEGIN{

# Global Variables
$smtpServer= # STMP Server IP ADDRESS 
$from=  # Email From
$logging="Enabled" # If Set to Enable Logging will be On Set to Disabled to Disable Logging
$logFile = # Path to Log File. ie. G:\mylog.csv
$testing="Disabled"# Disabled to Email Users
$testRecipient= # Testing Email
$support = # Support Email 
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
    $SqlServer = #Database Server IP Address 
    $SqlDBName =  # Database Name 
    # use these for a sql login.  Or you can modify the connection string to use integrated authentication and set the scheduled task to run under that user context (omit User ID and Password from the connect string).
    $SqlLoginUser = # Database username
    $SqlLoginPassword =  # Database Password 

    #Database Connection and Query
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server=$SqlServer;Database=$SqlDBName;Integrated Security=SSPI;Persist Security Info=False;User ID=$SqlLoginUser;Password=$SqlLoginPassword"
    $SqlQuery = "SELECT * FROM dbo.Host_Users
                 WHERE CONVERT(INT,GETDATE()) - CONVERT(INT,Pass_Reset_Date) >=36
                 AND CONVERT(INT,GETDATE()) - CONVERT(INT,Pass_Reset_Date) <=43 
                 AND Pass_Expire_Days = 42;"


    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $SqlQuery 
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $DataSet = New-Object System.Data.DataSet
    [void] $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close() # Close Connection to Database

}
PROCESS{

    $DataSet.Tables[0]|ForEach-Object{
    Write-Output $_  # Write output

    #Getting Users Details From Out-Put
    $name = $_.User_FullName # Get User Full Name
    $userName = $_.User_LoginID # Get User Login Name
    $emailaddress = $_.User_Email_Addr # Get Users Email Address
    $Last_Logon_Date = $_.last_logon_date # Get Users Last Logged on Date

    $days= ($_.Pass_Reset_Date - [datetime]::Today).Days + $_.Pass_Expire_Days # Getting Days Left.
    $daysleft = $days # vaildate
    $daysleft = "$days" # Add to Output


    if (($daysleft) -ge "1")
    {
        $messageDays ="$daysleft" + " days"
    }
    else
    {
        $messageDays = "today."
    }

    # Sending Email to User
    $subject="SFTP Password due to expire"   # Email Subject
    # Email Body Set Here.
    $body ="<html>
    <body>
    Dear $name,
    <p>Your SFTP password is due to expire in <b><font color=red>$messageDays</b></font><br>
    <p>Your SFTP Username is $userName.<br>
    <p>Any FTP Account that is expired will be unable to receive their Weekly Sub Account Passwords...
    <p>To Reset Passwords please do the Following;
    <p><li>please go to <b>https://</b></li><br>
    <p><li>On The Top Right Click on Change Password</li><br>
    <p><li>Enter in Your old Password followed by your New Password</li><br>

    <font color=red> Please Note: This is an unmonitored email Please do no respond to this email, if any issues please create System Ticket</font>

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
        Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -Cc $support -subject $subject -body $body -bodyasHTML -priority High  
        }

        }
END{}

