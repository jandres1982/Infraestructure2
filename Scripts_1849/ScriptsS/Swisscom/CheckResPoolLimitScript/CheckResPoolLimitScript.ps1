#===================================================================================#
#                                                                                   #
# CheckResPoolLimitScript.ps1                                                       #
# Powershell Script to send an alert when SetResPoolLimit Script did not run        #
#                                                                                   #
# Author: Erich Niffeler                                                            #
# Creation Date: 21.06.2016                                                         #
# Modified Date: 21.06.2016                                                         #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: $PW = powershell.exe D:\Scripts\Swisscom\CheckResPoolLimitScript.ps1     #
#                                                                                   #
#                                                                                   #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "vcenterscs@ch.schindler.com"
$To = "inf.dcwin.alerting.sls@ch.schindler.com","Erich.Niffeler@swisscom.com"
$Date = Get-Date -format d
$Subject = "WARNING! $Date SetResPoolLimit did not run for more than 45 Minutes"
$Path = "D:\Scripts\Swisscom\SetResPoolLimit\"
$Filename = Get-ChildItem ("$Path" +  "SetCPULimits*") | Sort {$_.LastWriteTime} | select -Last 1
$Now=Get-Date
$LogDate=$Filename.LastWriteTime
$Diff=New-TimeSpan -Start $LogDate -End $Now

$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

WARNING! $Date SetResPoolLimit did not run for more than 45 Minutes

Please check scheduled Task "Set_CPU_Ratio_vCenterSCS" on script server.

"@

# Send an Warning message when SetResPoolLimit script did not update the log for more than 45 Minutes
if ($Diff.TotalMinutes -gt 45) {
   #Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment
}