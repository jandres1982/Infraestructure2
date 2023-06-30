$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$date = $date = $(get-date -format yyyy-MM-ddTHH-mm)
$SnapshotReport = [System.Collections.ArrayList]::new()

Foreach ($sub in $subs)
{
    Select-AzSubscription -Subscription $sub -WarningAction SilentlyContinue
    $Rg = Get-AzResourcegroup | Where-Object {$_.ResourceGroupName -like "*Snapshot*"}
    $snaps = Get-AzResource -ResourceGroupName $rg.ResourceGroupName | Where-Object {$_.Name -like "*Snapshot*"}
    
    
    foreach ($snap in $snaps)
        {

         [datetime]$today = Get-Date  
         [datetime]$today_less = $today.AddDays(-7)
         [datetime]$snapdate = $snap.Tags.date
         #[datetime]$snapdate = $snaps[0].Tags.date
         if ($snapdate -lt $today_less)
         {
         $Alert = "MORE THAN 7 DAYS CHECK"
         }else
            {
            $Alert = "OK"
            }

        [void]$SnapshotReport.Add([PSCustomObject]@{
             Snapshot = $snap.Name
             Sub = $Sub
             Requestor = $snap.Tags.requester
             Date = $snap.Tags.date
             Location = $snap.Location
             Remove = $Alert
         }) #[void]$vmBackupReport.Add([PSCustomObject]@{
        }     
}
#Set-Location "D:\Snapshots\Scripts\Report\Logs\"
$report = 'Snapshot_'+"Report"+'_'+"$date"+'.csv'
$SnapshotReport | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report

$emails = $SnapshotReport.Requestor | Select-Object -unique

Foreach ($email in $emails)
{
$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = $email
#$to = "antoniovicente.vento@schindler.com"
$Subject = "Snapshots to Remove in Azure - Check Ownership"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = $report
$Body = @"

Please find attached the current Snapshots in Azure.

"@
#https://htmled.it/

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment
}