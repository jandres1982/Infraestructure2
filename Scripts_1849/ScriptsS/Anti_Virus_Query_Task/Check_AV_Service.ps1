$Servers = gc "D:\Scripts\Schindler\Anti_Virus_Query_Task\ServerList.txt"
#TrendMicro
$Destination = "c$\temp"

foreach ($Server in $Servers) {
if ((Test-Path -Path \\$Server\$destination)){

$Get_TM = Get-service -ComputerName $Server -name AMSP -ErrorAction SilentlyContinue
$Service_TM = $Get_TM.Name
if ($Service_TM -eq "amsp") { 
echo "$Server,TM" >> D:\Scripts\Schindler\Anti_Virus_Query_Task\Queries\AntiVirus_Check.txt
write-host "$Server has TM installed, please check"-ForegroundColor Yellow
}
else
{
}

#SEP
$Get_SEP = Get-service -ComputerName $Server -name "SepMasterService" -ErrorAction SilentlyContinue
$Service_SEP = $Get_SEP.Name

if ($Service_SEP -eq "SepMasterService") { #Comprobación de acceso
Write-Host "Server $Server have SEP Installed"
}
else
{
echo "$Server,NO_SEP" >> D:\Scripts\Schindler\Anti_Virus_Query_Task\Queries\AntiVirus_Check.txt
Write-host "$Server has not SEP Installed, please check" -ForegroundColor Cyan
}


if ($Service_SEP -ne "SepMasterService" -and $Service_TM -ne "AMSP" ) { #Comprobación de acceso
echo "$Server,NO_AV" >> D:\Scripts\Schindler\Anti_Virus_Query_Task\Queries\AntiVirus_Check.txt
Write-Host "$Server has no AV installed - Check Now!" -ForegroundColor Magenta
}
else
{
}
}
else{
Write-host "$Server with access denied"
}
}
