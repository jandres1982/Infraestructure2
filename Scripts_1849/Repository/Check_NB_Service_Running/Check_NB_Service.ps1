$Servers = gc "D:\Repository\Working\Antonio\Check_NB_Service_Running\Server_List.txt"
#TrendMicro
$Destination = "c$\temp"


echo "" > "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB.txt"
echo "" > "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB_Not_Recheable.txt"
echo "" > "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB_Not_Installed.txt"

foreach ($Server in $Servers) {
if ((Test-Path -Path \\$Server\$destination)){

$Get_Service = Get-service -ComputerName $Server -name "NetBackup Client Service" -ErrorAction SilentlyContinue
$Service_NB = $Get_Service.Name

if ($Service_NB -eq "NetBackup Client Service"){

echo "$Server,has Netbackup installed" >> "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB.txt"
Write-host "$Server with NB installed"

}
else{
write-host "$Server, no NB found"

echo "$Server, not NB Found" >> "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB_Not_Installed.txt"
}

}else{
Write-host "$Server not recheable"

echo "$Server, not Reachable" >> "D:\Repository\Working\Antonio\Check_NB_Service_Running\NB_Not_Recheable.txt"

}


}
