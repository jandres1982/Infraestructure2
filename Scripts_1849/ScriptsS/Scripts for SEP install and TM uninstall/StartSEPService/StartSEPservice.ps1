###########################################################################################
# 
# Author: David Bona
# Date: 22/03/2019
# Description: START Symantec EndPoint Protection service
# LastMod: 22/03/2018
#
###########################################################################################

$Serverlist = Get-Content 'C:\Users\admbonada\Desktop\scripts\serverlist.txt'
$Source = "\\SHHWSR1123.global.schindler.com\e$\Agents\SEP_14.0.3876.1100\smcstart.ps1"

Foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

    $Destination = "\\$Server\C$\temp"

    Copy-Item -Path $Source -Destination $Destination
    
    Write-Host "Starting SEP service in $Server, please wait until the service is started" -ForegroundColor Yellow
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\temp\smcstart.ps1}
    Write-Host "SEP service started successfully in $Server" -ForegroundColor Green

    Remove-Item -Path "$Destination\smcstart.ps1"

    } else {

    Write-Host "Server $Server is not reachable" -ForegroundColor Red
    }
}