
#vCenter Variables
$user = ''
$pswd = ''
$vCenter_Servers = ""


Connect-VIServer -Server $vCenter_Servers -User $user -Password $pswd

$report = foreach($cluster in Get-Cluster){
            foreach($Switch in Get-VirtualSwitch){
            foreach($datastore in Get-Datastore){
            foreach($Template in Get-Template){
              $obj = New-Object PSObject -Property @{
                  Cluster = $cluster.Name
                  DataStore = $datastore.name
                  Switch = $Switch.Name
                  Template = $vm.Template
            }

            $obj
        }

    }
  }
}

$report |

Select Cluster,DataStore,Switch,Template |
Export-Csv -Path C:\Scripts\Report5.csv -NoTypeInformation -UseCulture
