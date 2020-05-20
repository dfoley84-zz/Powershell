
$vCenter_Servers = ${env:vcenter}
$user = ${env:user}
$pswd = ${env:pass}

$Template = ${env:template}
Connect-VIServer -Server $vCenter_Servers -User $user -Password $pswd

Get-Template $Template |

Select Name,

    @{N='UUID';E={$_.ExtensionData.Config.Uuid}},

    @{N='Path';E={

        $templatePath = @()

        $parent = Get-View -Id $_.ExtensionData.Parent

        do{

            $templatePath += $parent.Name

            $parent = Get-View -Id $parent.Parent -ErrorAction SilentlyContinue

        } until($parent.Parent -eq $null)

        [array]::Reverse($templatePath)

        $templatePath -join '/'

    }}
