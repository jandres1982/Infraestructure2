$vm = $args[0]
$PSEmailServer = "smtp.eu.schindler.com"
$From = "antoniovicente.vento@schindler.com"
$To = "antoniovicente.vento@schindler.com"
$Date = Get-Date -format d
$Subject = "Server $vm is completed from Devops Script at $Date "
#$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "$Path$Filename"
$Body = @"
"@

#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body