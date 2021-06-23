$vm = $args[0]
$PSEmailServer = "smtp.eu.schindler.com"
$From = "david.sanchoiguaz@schindler.com"
$To = "0034691022611@sms.schindler.com"
$Date = Get-Date -format d
$Subject = "Server $vm is completed from Devops Script at $Date "
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"
This mail is being generated automatically by Schindler Powershell Script SPS (ventoa1)

Please check all the software has been Installed, in case you find any problems, please contact the Server Team.

SCC Server Competence Center - Schindler Support

"@
#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body