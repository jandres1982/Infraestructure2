$subs ="s-sis-am-nonprod-01" #added ventoa1
$subs = get-azsubscription -SubscriptionName "$subs" #added ventoa1
#$subs=get-azsubscription
$date = $(get-date -format yyyy-MM-ddTHH-mm)

$vmObject = [System.Collections.ArrayList]::new() #added ventoa1

foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub.Name
    Select-AzSubscription -Subscription "$sub"

    $vms=get-azvm
    foreach ($vm in $vms)
    {
        #$Status_vm = get-azvm -Name "$vm" -ResourceGroupName $vm.ResourceGroupName -Status
        #$vmObject = New-Object -TypeName psobject 
        [void]$vmObject.add([PSCustomObject]@{
        Subscription = $subs.name
        Name = $vm.Name
        Resource_Group = $vm.ResourceGroupName
        Location = $vm.Location
        #Status = $Status_vm.powerstate
        Operating_System = $vm.StorageProfile.OsDisk.OsType
        Size = $vm.HardwareProfile.VmSize 
        #Disk = $vm.StorageProfile.DataDisks.name
        Tag_serviceowner = $vm.Tags.serviceowner
        Tag_applicationowner = $vm.Tags.applicationowner
        Tag_technicalcontact = $vm.Tags.technicalcontact
        Tag_kg = $vm.Tags.kg
        Tag_costcenter = $vm.Tags.costcenter
        Tag_infrastructureservice = $vm.Tags.infrastructureservice
        })
    } 
}
$report = 'VMS_'+'_Report_'+"$date"+'.csv'
$vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report


$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "hanspeter.gut@schindler.com"

$Subject = "VMs Report"
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear Hanspeter,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Report of SIS VMs.</span></div>
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