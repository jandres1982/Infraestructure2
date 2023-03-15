$proc = cmd.exe /c "C:\Program Files\Notepad++\notepad++.exe" "D:\Repository\Working\Antonio\EPM_Landesk\ServerList.txt"
$Servers = gc "D:\Repository\Working\Antonio\EPM_Landesk\ServerList.txt"

foreach ($Server in $Servers)
{
Start-Job -ScriptBlock {param($server);
Copy-Item "D:\provision\Landesk_Agents\SSA_2022_SU2_V3.exe" -Destination "\\$server\c$\temp" -force; 
$result = Test-Path "\\$server\c$\temp\SSA_2022_SU2_V3.exe";
Write-Output "$server, $result" >> "D:\Repository\Working\Antonio\EPM_Landesk\Copyreport.txt";
if ($result)
{
Invoke-Command -ComputerName $Server -ScriptBlock {cmd.exe /c "c:\temp\SSA_2022_SU2_V3.exe"}
}
} -ArgumentList $server

}