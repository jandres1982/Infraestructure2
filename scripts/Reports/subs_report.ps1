#Sub Report for Microsoft
##################################################################
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$SubObject = [System.Collections.ArrayList]::new() 
$subs = get-azsubscription
foreach ($sub in $subs)
{
    Get-AzSubscription -SubscriptionName $sub.Name
    [void]$SubObject.add([PSCustomObject]@{
    Subscription = $sub.name
    ID = $sub.id
    State = $sub.state
    })
     
}
$report = 'Subs_'+'_Report_'+"$date"+'.csv'
$SubObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "johannes.gappmaier@microsoft.com","priska.jaeggi@microsoft.com","alfonso.marques@schindler.com","nahum.sancho@schindler.com","alberto.mischi@schindler.com"

$Subject = "Schindler Subscriptions Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear Priska and Johannes ,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Report of Schindler Subs.</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Best regards,</span></div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<p><span style="font-size: medium; font-family: arial, helvetica, sans-serif; color: #ff0000;">Schindler Server Team - DevOps Automated Report</span></p>
<p>&nbsp;</p>
</div>
<div>&nbsp;</div>
"@
#https://htmled.it/

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -BodyAsHtml