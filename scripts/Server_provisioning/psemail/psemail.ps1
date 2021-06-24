$vm = $args[0]
$rg = $args[1]
$re_email = $args[2]
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$To = "0034691022611@sms.schindler.com","$re_email"
$Subject = "Server $vm was completed with Schindler Devops Script on $rg"
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"
Server $vm has been provisioned in $rg. 
- Check Backup is Enabled.
- Check SIM local admin group is added.
- Check Updates were Installed.
- Check MMA agent is connected to workspaces.
"@
#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body