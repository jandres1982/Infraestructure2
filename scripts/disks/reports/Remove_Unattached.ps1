$sub = "s-sis-eu-prod-01"
Select-AzSubscription "s-sis-eu-prod-01"
#$rg = "RG-SHH-PROD-EPO-01"
#$rgs = @("RG-SHH-PROD-EPO-01","RG-SHH-PROD-LOTUSNOTES-01","RG-SHH-PROD-LOTUSNOTES2012-01","RG-SHH-PROD-MCAFEEEPO-01","RG-SHH-PROD-READSOFT-01","RG-UKC-PROD-FILESERVER-01","RG-WII-PROD-FILESERVER-01")
foreach ($rg in $rgs)
{
    Write-host "$rg"
$(Get-AzDisk -ResourceGroupName $rg | Where-Object {$_.Diskstate -eq "Unattached"}).name.count
$(Get-AzDisk -ResourceGroupName $rg | Where-Object {$_.Diskstate -eq "Unattached"}).name
#Get-AzDisk -ResourceGroupName $rg | Where-Object {$_.Diskstate -eq "Unattached"} | Remove-AzDisk -force
}

