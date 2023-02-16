$destination = "\\$server\c$\temp"
$date = get-date -UFormat "%HH_%MM"

$Nubes4_servers = gc "D:\Repository\Working\Antonio\Nubes4ToolsUpdate\Nubes4ToolsUpdate.txt"


Foreach ($Server in $Nubes4_servers)
{

Write-Host "VMtools Upgrade for $Server will start now" -ForegroundColor Green
Write-Host ""

If ((Test-path -path "\\$server\c$\temp"))
        {
        Write-host "VmWare Tools will be copied to destination server $server, please wait..." -ForegroundColor Yellow
        Copy-Item -Path "D:\Repository\Working\Antonio\Final_Provisioning_Script\Source\VmTools" -Destination "\\$server\c$\temp\" -Force -Recurse
        Write-host "VmWare Tools file should be copied to c:\temp, please check" -ForegroundColor Blue
        invoke-command -ComputerName $server -ScriptBlock {powershell.exe c:\temp\vmtools\setup64.exe /s /v “/qn reboot=r”}
        write-host "VmWare tools should be installed please check" -ForegroundColor Green
       # Remove-Item -Path "\\$server\c$\temp\Vmtools.zip"
       # Remove-Item -Path "\\$server\c$\temp\VmTools\" -Recurse -Force
        }else
             {Write-host "$Server can't be reached"}

}