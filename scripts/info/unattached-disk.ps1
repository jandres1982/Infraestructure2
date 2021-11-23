Set-AzContext -Subscription s-sis-eu-prod-01
$(Get-AzDisk | Where-Object {$_.Diskstate -eq "Unattached"}).Name

