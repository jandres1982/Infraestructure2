###########################################################################################
# 
# Author: David Bona
# Date: 22/03/2019
# Description: STOP Symantec EndPoint Protection service 
# LastMod: 22/03/2018
#
###########################################################################################

$Serverlist = Get-Content 'C:\Users\admbonada\Desktop\scripts\serverlist.txt'
$Source = "\\SHHWSR1123.global.schindler.com\e$\Agents\SEP_14.0.3876.1100\smcstop.ps1"

Foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

    $Destination = "\\$Server\C$\temp"

    Copy-Item -Path $Source -Destination $Destination
    
    Write-Host "Stopping SEP service in $Server, please wait until the service is stopped" -ForegroundColor Yellow
    Invoke-Command -ComputerName $Server -ScriptBlock {C:\temp\smcstop.ps1}
    Write-Host "SEP service stopped successfully in $Server" -ForegroundColor Green

    Remove-Item -Path "$Destination\smcstop.ps1"

    } else {

    Write-Host "Server $Server is not reachable" -ForegroundColor Red
    }
}