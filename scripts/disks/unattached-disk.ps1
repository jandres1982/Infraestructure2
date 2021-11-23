Set-AzContext -Subscription s-sis-eu-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-eu-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-am-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-am-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-ap-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-ch-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt

Set-AzContext -Subscription s-sis-ch-nonprod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name >> Unattached-Disk.txt