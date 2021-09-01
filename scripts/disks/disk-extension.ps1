##Define VM variables##
$VMName = Get-AzVm -Name $(vm)
$rg=$VMName.ResourceGroupName

##Deallocate VM##
Stop-AzVM -ResourceGroupName $rg -Name $(vm) -Force

##Verify deallocate status##
Get-AzVM -ResourceGroupName $rg -Name $(vm) -Status

##Get Vistual disks##
$osDiskName = $VMName.StorageProfile.OSDisk.Name

##Get Virtual disks id##
$disk = Get-AzDisk -ResourceGroupName $rg -DiskName $osDiskName
$disk.DiskSizeGB = $(disk-size)

##Update disk size##
Update-AzDisk -ResourceGroupName $rg -DiskName $osDiskName -Disk $disk

##Verify disk extension##
Get-AzDisk -ResourceGroupName $rg -DiskName $osDiskName

##Start vm again##
Start-AzVM -ResourceGroupName $rg -Name $(vm)