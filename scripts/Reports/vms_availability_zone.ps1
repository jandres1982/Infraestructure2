$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
$date = $(get-date -format yyyy-MM-ddTHH-mm)

$vmObject = [System.Collections.ArrayList]::new() 

foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub.Name
    Select-AzSubscription -Subscription "$sub"

    $vms=get-azvm
    foreach ($vm in $vms)
    {
        [void]$vmObject.add([PSCustomObject]@{
        Subscription = $sub.name
        Name = $vm.Name
        Resource_Group = $vm.ResourceGroupName
        Location = $vm.Location
        AvailabilityZone = $vm.zones[0]
        })
        echo $vmObject
    } 
}
$report = 'VMS_'+'Zone_'+'Report_'+"$date"+'.csv'
$vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "alfonso.marques@schindler.com","nahum.sancho@schindler.com"

$Subject = "VMs Zone Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear all,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Zone Report of SIS VMs.</span></div>
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