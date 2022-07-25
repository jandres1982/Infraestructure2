#$date = $(get-date -format yyyy-MM-ddTHH-mm)
#Get-AzSubscription | Export-Csv -Path schindler_subs_$date.csv

###################################################################

#$PSEmailServer = "smtp.eu.schindler.com"
#$From = "scc-support-zar.es@schindler.com"
#$to = "nahum.sancho@schindler.com","alfonso.marques@schindler.com"

#$Subject = "Schindler Subscrtiptions Report"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
#$Attachment = "schindler_subs_$date.csv"
#$Body = @"
#Dear Priska,

#Please find attached the Report of Schindler´s subscriptions.

#Best regards

#Schindler Server Team - Devops Automated Report
#"@

#Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment


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
    State = $sub.name
    })
     
}
$report = 'Subs_'+'_Report_'+"$date"+'.csv'
$SubObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "alfonso.marques@schindler.com","nahum.sancho@schindler.com"

$Subject = "Schindler Subscriptions Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear Priska,</span></div>
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