Import-Module ActiveDirectory

$UserNames = Import-Csv 'C:\temp\TestGroup.csv'
$ActiveDirectory = Get-ADGroupMember 'TestGroup' | select sAMAccountName

$Match = @()
$NotMatch = @()

foreach($user in $ActiveDirectory){

    if($UserNames.sAMAccountName -eq $user.sAMAccountName){
        
        $Match += $user

    }else{

        $NotMatch += $user
        
    }
}

foreach($notuser in $NotMatch){
    #Write-Host $notuser
    Remove-ADGroupMember -Identity "TestGroup" -Members $notuser.sAMAccountName -Confirm:$false
}
