$subs=get-azsubscription
$date = $(get-date -format yyyy-MM-ddTHH-mm)
foreach ($sub in $subs)
{
    set-azcontext -Subscription $sub.Name
    $vms=get-azvm
    foreach ($vm in $vms)
    {
        
        $vmObject = New-Object -TypeName psobject 

        $vmObject | Add-Member -MemberType NoteProperty -Name Subscription -Value $sub
        $vmObject | Add-Member -MemberType NoteProperty -Name Name -Value $vm.Name
        $vmObject | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $vm.ResourceGroupName
        $vmObject | Add-Member -MemberType NoteProperty -Name Location-Value $vm.Location
        $vmObject | Add-Member -MemberType NoteProperty -Name Size -Value $vm.HardwareProfile.VmSize
        $vmObject | Add-Member -MemberType NoteProperty -Name OsType -Value $vm.StorageProfile.OsDisk.OsType
        $vmObject | Add-Member -MemberType NoteProperty -Name ServiceOwner -Value $vm.Tags.serviceowner
        $vmObject | Add-Member -MemberType NoteProperty -Name ApplicationOwner -Value $vm.Tags.applicationowner
        $vmObject | Add-Member -MemberType NoteProperty -Name TechnicalContact -Value $vm.Tags.technicalcontact
        $vmObject | Add-Member -MemberType NoteProperty -Name KG -Value $vm.Tags.kg
        $vmObject | Add-Member -MemberType NoteProperty -Name CostCenter -Value $vm.Tags.costcenter
        $vmObject | Add-Member -MemberType NoteProperty -Name InfrastructureService -Value $vm.Tags.infrastructureservice
        $report = 'VMS_'+'_Report_'+"$date"+'.csv'
        $vmObject  | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $report
    } 
}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "nahum.sancho@schindler"

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
