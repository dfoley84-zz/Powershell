$ipaddress = ((Test-Connection $env:computername -Count 1).ipv4address).ipaddresstostring

#Getting Gateway IP Address 
$Gateway = netsh interface ip show config | findstr "Default Gateway:"
$GatewayArray = $Gateway.Split(":")
$GatewayArray1 = $GatewayArray[-1]
$GatewayValue = $GatewayArray1.Trim()

#getting Subnet
$Subnet = netsh interface ip show config | findstr "Subnet prefix:"
$SubnetArray = $Subnet.split("/")
$SubnetArray1 = $SubnetArray[1].Split("(mask")
$SubnetArray2 = $SubnetArray1[-1].Split(")")
$SubnetValue = $SubnetArray2[0]
$SubnetValue1 = $SubnetValue.Trim()

#New-NetIPAddress -IPAddress $ipaddress -PrefixLength $SubnetValue -DefaultGateway $GatwayValue
$wmi = Get-WmiObject win32_networkadapterconfiguration -filter “ipenabled = ‘true'”
$wmi.EnableStatic($ipaddress, $SubnetValue1)
$wmi.SetGateways($GatewayValue, 1)
