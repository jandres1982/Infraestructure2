$date = $(get-date -format yyyy-MM-ddTHH-mm)
Get-AzSubscription | Export-Excel -Path schindler_subs_$date.xls 

###################################################################

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "nahum.sancho@schindler.com"

$Subject = "Schindler Subscrtiptions Report"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = "schindler_subs_$date.xls"
$Body = @"
Dear Priska,

Please find attached the Report of Schindler´s subscriptions.

Best regards

Schindler Server Team - Devops Automated Report
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment
