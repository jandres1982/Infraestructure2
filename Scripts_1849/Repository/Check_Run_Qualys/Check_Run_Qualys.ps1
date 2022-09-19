$Servers = gc "D:\Repository\Working\Antonio\Check_Run_Qualys\server_list.txt"
#TrendMicro
$Destination = "c$\temp"

foreach ($Server in $Servers) {
if ((Test-Path -Path \\$Server\$destination)){

$Get_q = Get-service -ComputerName $Server -name QualysAgent -ErrorAction SilentlyContinue
$Service_q = $Get_q.Name
if ($Service_q -eq "QualysAgent") { 
echo "$Server,Qualys" >> D:\Repository\Working\Antonio\Check_Run_Qualys\Qualys_Installed.txt
write-host "$Server has Qualys installed, please check"-ForegroundColor Green
Get-service -ComputerName $Server -name QualysAgent | Restart-Service
Get-service -ComputerName $Server -name QualysAgent
}
else
{
write-host "$Server has not the Qualys installed, please check"-ForegroundColor Yellow

}
}
}