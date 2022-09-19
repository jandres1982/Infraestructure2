#===================================================================================#
#                                                                                   #
# SendRVToolsReport_SHH.ps1                                                             #
# Powershell Script to send latest RVTools export per Mail                          #
#                                                                                   #
# Author: Erich Niffeler                                                            #
# Creation Date: 21.06.2016                                                         #
# Modified Date: 21.06.2016                                                         #
# Version: 01.00.00                                                                 #
#                                                                                   #
# Example: $PW = powershell.exe D:\Scripts\Swisscom\SendRVToolsReport.ps1           #
#                                                                                   #
#                                                                                   #
#                                                                                   #
#===================================================================================#


$PSEmailServer = "smtp.eu.schindler.com"
$From = "vcentershh@ch.schindler.com"
$To = "ServiceManagement.Schindler@swisscom.com"
$Date = Get-Date -format d
$Subject = "SHH RVTools Exports $Date"
$Path = "D:\Scripts\Schindler\RVTools\Export_SHH\"
$Filename = Get-ChildItem $Path -Name "RVTools_export*" | select -Last 1
$Attachment = "$Path$Filename"
$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.

"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment