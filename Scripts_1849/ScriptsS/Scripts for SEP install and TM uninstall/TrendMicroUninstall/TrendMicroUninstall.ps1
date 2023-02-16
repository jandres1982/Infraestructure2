###########################################################################################
# 
# Author: David Bona & Antonio Vicente
# Date: 22/03/2019
# Description: TrendMicro AV Agent Uninstall for Windows Servers
# LastMod: 22/03/2018
#
###########################################################################################

$Serverlist = Get-Content "D:\Scripts\Schindler\FinalScripts\serverlist.txt"

Foreach ($Server in $Serverlist) {

if (Test-Connection -ComputerName $Server -Count 1 -Quiet) {

    Write-Host "Uninstalling TrendMIcro AV Agent in $Server, please wait until the uninstall is complete" -ForegroundColor Yellow
    Invoke-Command -ComputerName $Server -ScriptBlock {
    (& cmd /c "MsiExec.exe /X{851A3FC2-BEF1-47F0-882A-A4BE5E0133EC}" /qn REBOOT=REALLYSUPPRESS)
    (& cmd /c "MsiExec.exe /X{EF0664BA-D655-493C-A55D-024917145FB1}" /qn REBOOT=REALLYSUPPRESS)
    }
    Write-Host "TrendMIcro AV Agent uninstalled successfully in $Server" -ForegroundColor Green

} else {

    Write-Host "Server $Server is not reachable" -ForegroundColor Red
    }
}