
#vCenter Variables
$user = ${env:user}
$pswd = ${env:pass}

$FileName = "C:\Scripts\ReportCapacity.csv"
$vCenter_Servers =

#Removing Old Data File

if (Test-Path $FileName) {
  Remove-Item $FileName
}

foreach($VCenter in $vCenter_Servers) {
Connect-VIServer -Server $VCenter -User $user -Password $pswd
Get-Datacenter -PipelineVariable dc |
ForEach-Object -Process {
    Get-VMHost -Location $dc -PipelineVariable esx |
       ForEach-Object -Process {
       Get-Datastore -VMHost $esx -PipelineVariable ds |

               Select @{N='vCenter';E={([uri]$dc.ExtensionData.Client.ServiceUrl).Host}},

                   @{N='Datacenter';E={$dc.Name}},
                   @{N='VMHost';E={$esx.Name}},
                   @{N='Datastore';E={$ds.Name}},
                   @{N='DataStoreFreeGB';E={[math]::Round($ds.FreeSpaceGB)}},
                   @{N='DataStoreCapacityGB';E={[math]::Round($ds.CapacityGB)}},
                   @{N='DataStorep';E={($ds.FreeSpaceGB / $ds.CapacityGB).ToString("P")}}
    }
    } | Export-Csv -Path $FileName -NoTypeInformation -UseCulture -append 

Disconnect-VIServer -Server $VCenter -Force -Confirm:$false
}
