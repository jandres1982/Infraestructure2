#=======================================================================================================#
#                                                                                                       #
# CopyFiles_SendMail.ps1                                                                                #
# Powershell Script to copy latest reports from RVTools, rename files, and inform by mail               #
#                                                                                                       #
# Author: Alfonso Marqués                                                                               #
# Creation Date: 03.03.2017                                                                             #
# Modified Date: 03.03.2017                                                                             #
# Version: 01.00.00                                                                                     #
#                                                                                                       #
# Example: $PW = powershell.exe D:\Scripts\Schindler\Microsoft\Hadinata\CopyFiles_SendMail.ps1          #
#                                                                                                       #
#=======================================================================================================#


$DestPath = "\\infv0001\prjinf\GIS_DC_Move\Inventory\backup"
$DestFolder = "RVTools - $(Get-Date -Format MMM)-$(Get-Date -Format dd)"
New-Item -ItemType Directory -Path $DestPath -Name $DestFolder

$PathSCS = "D:\Scripts\Schindler\RVTools\Export_SCS\"
$PathSHH = "D:\Scripts\Schindler\RVTools\Export_SHH\"
$PathZAP = "D:\Scripts\Schindler\RVTools\Export_ZAP\"

$FilenameSCS = Get-ChildItem $PathSCS -Name "RVTools_export*" | select -Last 1
$FilenameSHH = Get-ChildItem $PathSHH -Name "RVTools_export*" | select -Last 1
$FilenameZAP = Get-ChildItem $PathZAP -Name "RVTools_export*" | select -Last 1

$FullDestPath = "$($DestPath)\$($DestFolder)\"

Copy-Item "$($PathSCS)$($FilenameSCS)" "$($FullDestPath)" 
Copy-Item "$($PathSHH)$($FilenameSHH)" "$($FullDestPath)" 
Copy-Item "$($PathZAP)$($FilenameZAP)" "$($FullDestPath)" 

Rename-Item "$($FullDestPath)$($FilenameSCS)" "vCenterSwisscom - RVTools.xls"
Rename-Item "$($FullDestPath)$($FilenameSHH)" "vCenterSHH - RVTools.xls"
Rename-Item "$($FullDestPath)$($FilenameZAP)" "vCenterZAP - RVTools.xls"

$PSEmailServer = "smtp.eu.schindler.com"
$From = "SCC-ZAR@schindler.com"
$To = "martin.hadinata@schindler.com"
$BCC1 = "alfonso.marques@schindler.com"
$BCC2 = "fernando.garcia.pavia@schindler.com"
$Date = Get-Date -format d
$Subject = "RvTools reports $Date"

$Body = @"
Dear Martin.

RVTools reports are created and located in the folder.

This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.
"@

Send-MailMessage -From $From -To $To -BCC $BCC1, $BCC2 -Subject $Subject -Body $Body