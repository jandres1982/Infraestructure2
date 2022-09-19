###########################################################################################
# 
# Author: David Bona
# Date: 22/03/2019
# Description: Symantec EndPoint Protection installation for Windows Servers 
# LastMod: 22/03/2018
#
###########################################################################################

$Serverlist = Get-Content "D:\Scripts\Schindler\FinalScripts\serverlist.txt"
$Source = "\\SHHWSR1123.global.schindler.com\e$\Agents\SEP_14.0.3876.1100\"

Foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

    $Destination = "\\$Server\C$\temp"

    if (!(Test-Path -path $Destination)) {
        New-Item $Destination -Type Directory
    }
    Write-Host "Copying SEP temporary folder in $Server" -ForegroundColor Green
    Copy-Item -Path $Source -Destination $Destination -Recurse
    
    Write-Host "Starting SEP installation in $Server, please wait until the installation is complete" -ForegroundColor Yellow
    Invoke-Command -ComputerName $Server -ScriptBlock { & cmd /c "msiexec.exe /i c:\temp\SEP_14.0.3876.1100\Sep64.msi" /qn ADVANCED_OPTIONS=1 CHANNEL=100}
    Write-Host "SEP installation complete in $Server" -ForegroundColor Green
    
    Remove-Item -Path "$Destination\SEP_14.0.3876.1100" -Recurse
    Write-Host "SEP temporary folder removed in $Server" -ForegroundColor Green

    } else {

    Write-Host "Server $Server is not reachable" -ForegroundColor Red
    }
}