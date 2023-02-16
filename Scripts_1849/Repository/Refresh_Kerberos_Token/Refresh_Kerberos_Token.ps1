Start-Process notepad++ "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Server_list.txt" -Wait

$Servers = gc "D:\Repository\Working\Antonio\Windows_Update_Force_Patching\Get-Windows-Update-Group\Server_list.txt"

$creds = Get-Credential

Foreach ($Server in $Servers)
{
if (Test-Path \\$Server\c$\temp)
{
Copy-Item -Path "D:\Repository\Working\Antonio\Refresh_Kerberos_Token\run.cmd" -Destination \\$Server\c$\temp

Invoke-Command -ComputerName $Server -ScriptBlock {cmd.exe /c c:\temp\run.cmd} -Credential ($creds) -Verbose

#sleep 1

#Remove-item -Path \\$server\c$\temp\run.cmd

}else
{ Write-Host "Server $server is unrecheable"
}


}


