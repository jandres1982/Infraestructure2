
$Servers = gc "D:\Repository\Working\Antonio\WSUS\Server_List1.txt"

foreach ($computer in $Servers) {

Invoke-Command -ComputerName $computer -ScriptBlock {wuauclt.exe /detectnow}

Invoke-Command -ComputerName $computer -ScriptBlock {wuauclt.exe /reportnow}

echo "Server $Computer reporting"

}