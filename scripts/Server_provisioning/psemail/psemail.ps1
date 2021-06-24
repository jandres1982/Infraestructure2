$vm = $args[0]
$PSEmailServer = "smtp.eu.schindler.com"
$From = "david.sanchoiguaz@schindler.com"
$To = "0034691022611@sms.schindler.com","0034699559798@sms.schindler.com"
$Date = Get-Date -format d
$Subject = "Server $vm is completed from Devops Script at $Date "
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"
Server $vm has been provisioned, please check backup is enable and the correct IP address.
Remeber to create the SIM local admin group and added to the server
"@
#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body