#User Variables
$user = ${env:user}
$pswd = ${env:pass}

$vCenter_Servers = 

foreach($server in $vCenter_Servers){
Connect-VIServer -Server $server -User $user -Password $pswd
  
Get-ContentLibraryItem -Server $server -PipelineVariable ct |
ForEach-Object -Process {
    Get-ContentLibrary -Server $server -Name $ct.ContentLibrary -PipelineVariable content |
         Select @{N='vCenter';E={$server}},
                @{N='ContentLibrary';E={$content.Name}},
                @{N='DataStore';E={$content.Datastore}},
                @{N='Template';E={$ct.Name}}
         } | Export-Csv -Path c:\Scripts\contentlibrary.csv -NoTypeInformation -UseCulture -append
Disconnect-VIServer $server -Confirm:$false
}
