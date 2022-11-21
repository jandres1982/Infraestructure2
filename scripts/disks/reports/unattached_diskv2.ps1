$date = $(get-date -format yyyy-MM-ddTHH-mm)
$subs = Get-AzSubscription 
$diskObject = [System.Collections.ArrayList]::new()
foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub.Name
    Select-AzSubscription -Subscription "$sub"

    $disks=Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}
   
    foreach ($disk in $disks)
    {
        [void]$diskObject.add([PSCustomObject]@{
        Subscription = $sub.name
        Name = $disk.Name
        Resource_Group = $disk.ResourceGroupName
        Location = $disk.Location
        State = $disk.Diskstate
        })
    } 
}

$report = 'Disks_'+'_Report_'+"$date"+'.csv'
$diskObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report


$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "nahum.sancho@schindler.com"

$Subject = "Unattached Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear all,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Report of Unattached Disks.</span></div>
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
