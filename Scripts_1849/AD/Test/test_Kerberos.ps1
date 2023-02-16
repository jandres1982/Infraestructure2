remove-item D:\alb\test\ServerList.txt -ErrorAction SilentlyContinue
Start-Process notepad++ "D:\alb\test\ServerList.tx" -Wait

$Servers = Get-Command "D:\alb\test\ServerList.tx"

$creds = Get-Credential
Foreach ($Server in $Servers)
{
if (Test-Path \\$Server\c$\temp)
{
Copy-Item -Path "D:\alb\test\run.cmd" -Destination \\$Server\c$\temp

Invoke-Command -ComputerName $Server -ScriptBlock {cmd.exe /c c:\temp\run.cmd} -Credential ($creds) -Verbose

}else
{ Write-Host "Server $server is unrecheable"
}
