
#vCenter Variables
$user = ${env:user}
$pswd = ${env:pass}
$vCenter_Servers = ""

Connect-VIServer -Server $vCenter_Servers -User $user -Password $pswd
Get-Datacenter -PipelineVariable dc |
ForEach-Object -Process {

Get-VMHost -Location $dc -PipelineVariable esx |

    ForEach-Object -Process {
        Get-Datastore -VMHost $esx -PipelineVariable ds |
        ForEach-Object -Process {

            if(Get-Template -Datastore $ds -Location $esx){
               Get-Template -Datastore $ds -Location $esx -PipelineVariable template |

               Select @{N='vCenter';E={([uri]$dc.ExtensionData.Client.ServiceUrl).Host}},
                   @{N='Datacenter';E={$dc.Name}},
                   @{N='Cluster';E={(Get-Cluster -VMHost $esx).Name}},
                   @{N='Network' ;E={(Get-VirtualPortGroup -VMHost $esx).Name -join ','}},
                   @{N='Datastore';E={$ds.Name}},
                   @{N='Template';E={$template.Name}}

            }

            else{

                '' | Select @{N='vCenter';E={([uri]$dc.ExtensionData.Client.ServiceUrl).Host}},
                   @{N='Datacenter';E={$dc.Name}},
                   @{N='Cluster';E={(Get-Cluster -VMHost $esx).Name}},
                   @{N='Network' ;E={(Get-VirtualPortGroup -VMHost $esx).Name -join ','}},
                   @{N='VMHost';E={$esx.Name}},
                   @{N='Datastore';E={$ds.Name}},
                   @{N='Template';E={$template.Name}}

            }

        }

    }

} | Export-Csv -Path C:\Scripts\Report6.csv -NoTypeInformation -UseCulture
