$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"


$Subject = "Server Snap task on $(virtualmachine) was completed with Schindler Devops Script"

$Body = @"

Server Snap task on $(virtualmachine) was completed.
The snap will be removed on $(retentiondate)

Thanks for using Devops for Schindler Servers!
"@


Send-MailMessage -From $From -To $(To) -Subject $Subject -Body $Body