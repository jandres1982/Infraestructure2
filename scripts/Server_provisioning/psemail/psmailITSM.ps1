$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$To = "support@ch.schindler.com"
$cc = "javier.cabezudo@schindler.com"
$Subject = "Test From Schindler Cloud team"
$Body = @"
This is a test notification.
Thanks,
Antonio Vento and Javier Cabezudo.
Test File is also attached.
"@
Send-MailMessage -From $From -To $To -Cc $cc -Subject $Subject -Body $Body -Attachments .\README.md