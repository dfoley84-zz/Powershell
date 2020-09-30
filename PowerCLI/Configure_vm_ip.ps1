$VMName = ''
$user = ''
$pass = ''

$IP = ''
$SNM = ''
$GW = ''
$DNS1 = ''
$DNS2 = ''

$cred = Get-Credential
Connect-VIServer -Server -Credential $cred

$Network = Invoke-VMScript -VM $VMName -ScriptType Powershell -ScriptText "(gwmi Win32_NetworkAdapter -filter 'netconnectionid is not null').netconnectionid" -GuestUser $user -GuestPassword $pass
$NetworkName = $Network.ScriptOutput
$NetworkName = $NetworkName.Trim()

Write-Host "Setting IP address for $VMname..." -ForegroundColor Yellow


$netsh = "c:\windows\system32\netsh.exe interface ip set address ""$NetworkName"" static $IP $SNM $GW"
$netsh2 = "c:\windows\system32\netsh.exe interface ip set dnsservers ""$NetworkName"" static $DNS1"
$netsh3 = "c:\windows\system32\netsh.exe interface ip add dnsservers ""$NetworkName"" $DNS2"


Invoke-VMScript -VM $VMname -GuestUser $user -GuestPassword $pass  -ScriptType bat -ScriptText $netsh 
Invoke-VMScript -VM $VMname -GuestUser $user -GuestPassword $pass -ScriptType bat -ScriptText $netsh2 
Invoke-VMScript -VM $VMname -GuestUser $user -GuestPassword $pass -ScriptType bat -ScriptText $netsh3 


Write-Host "Setting IP address completed." -ForegroundColor Green
