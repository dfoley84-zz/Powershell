#Parsing Jenkins Variables to PowerShell using ${env.parameterName}
$user = ${env.user}
$pswd = ${env.pass}


Connect-VIServer -Server ${env.cluster} -User $user -Password $pswd

#Getting All ESXi Hosts That are part of a Giving Cluster
$vmhosts = Get-Cluster "Test-Cluster" | Get-VMHost

#Doing a Loop on ESXi Hosts within a Cluster:
foreach ($vmhost in $vmhosts) {


#Setting Host to Maintenance
 Set-VMHost -VMHost $vmhost -State Maintenance

# Using an Until loop -> Until Connection State is True 
 Do {
    Write-Host "Host is Entering Maintenance Mode"
    Start-Sleep -s 15

    if(Get-VMHost $vmhost | Where-Object {$_.ConnectionState -eq 'Connected'}) {
           Write-Host "Host is Still Entering Maintenance Mode"
           Start-Sleep -s 60
        }#End If 

    else {
        Write-Output "Host Is Now in Maintance Mode"
    } # End Else
}#End DO
 Until (Get-VMHost $vmhost | Where-Object {$_.ConnectionState -eq 'Maintenance'})

#Upgrading ESXiHost --> To-DO


#Rebooting ESXi Host
Restart-VMHost $vmhost -force -Confirm:$false

#Using an Until Loop -> Until PowerState is Powered-On
Do{
    Write-Host "Server is Currently being Reborted"
    Start-Sleep -s 400
    if(Get-VMHost $vmhost | Where-Object {$_.PowerState -ne 'PoweredOn'}) {
        Write-Host "Server Is Still Being Rebooted"
        Start-Sleep -s 90
    }#If Statement 
    else{
      Write-Host "Server Is Now Online"
    }
 }#End Do
 Until(Get-VMHost $vmhost | Where-Object {$_.PowerState -eq 'PoweredOn'})

#Exit Host From Maintance Mode
Set-VMHost -VMhost $vmhost -State Connected

Do{
    Write-Host "Server is Currently Exiting Maintance Mode"
    Start-Sleep 30

    if(Get-VMHost $vmhost | Where-Object {$_.PowerState -eq 'Maintenance'}) {
    Write-Host "Server is still Exiting Maintance Mode"
    Start-Sleep 30
    }
    else{
        Write-Host "Server is After Exiting Maintance Mode"
        }
  } #Exit Do
  Until(Get-VMHost $vmhost | Where-Object {$_.PowerState -ne 'Maintenance'})
 

#Checking Status of ESXi
$StatusCheck = Get-VMHost $vmhost 
if($StatusCheck | Where-Object {$_.ConnectionState -eq 'Connected'}) {
    Write-Host "Server is Connected"
 else {
        Write-Host "ESXI HOST is Still Not In ConnectionState" $vmhost
        Break Script
} #Exit Else 

}#End If

}#End ForEach


