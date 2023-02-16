$Servers = gc "D:\Scripts\Schindler\Querry_Zabbix_Agent\ServerList.txt"
#TrendMicro
#$Destination = "c$\temp"

foreach ($Server in $Servers) {

if ((Test-Path -Path \\$Server\$destination)){

$Get_TM = Get-service -ComputerName $Server -name "Zabbix Agent" -ErrorAction SilentlyContinue
$Service_TM = $Get_TM.Name
if ($Service_TM -eq "Zabbix Agent") { #Comprobación de acceso
write-host "$Server has the Zabbix agent" -ForegroundColor Yellow
}
else {
write-host "$Server has NOT the Zabbix agent" -ForegroundColor Blue
}

}
else {
Write-host "$Server with access denied"
}

}
