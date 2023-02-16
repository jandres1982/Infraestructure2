
$PSEmailServer = "smtp.eu.schindler.com"
$From = "antoniovicente.vento@schindler.com"
$To = "antoniovicente.vento@schindler.com"
$Date = Get-Date -format d
$Subject = "Test email from PowerShell Script $Date"
$Path = "D:\Repository\Working\Antonio\PS_Email\Test_attachments\"
$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = "$Path$Filename"
$Body = @"
This mail is being generated automatically by a scheduled task.
Please, do not reply.

In case you find any problems, please contact the server team.

Antonio

"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body "$Body" -Attachments $Attachment