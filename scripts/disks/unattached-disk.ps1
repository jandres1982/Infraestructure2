$date = $(get-date -format yyyy-MM-ddTHH-mm)

Set-AzContext -Subscription s-sis-eu-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-eu-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-am-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-am-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-ap-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-ch-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

Set-AzContext -Subscription s-sis-ch-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> "Unattached_Disk_Report_$date.txt"

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com", "alfonso.marques@schindler.com", "nahum.sancho@schindler.com"

$Subject = "Unattached Disks"
$Attachment = "Unattached_Disk_Report_$date.txt"
$Body = @"
Dear team,

Please find attached the Report for Unattached Disks.


"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment


