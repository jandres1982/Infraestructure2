Function SQL_Disk
{
Get-Disk | Where partitionstyle -eq ‘raw’ | Initialize-Disk -PartitionStyle GPT -PassThru
New-Partition -AssignDriveLetter "2" -UseMaximumSize |
Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “SYSDB” -Confirm:$false
New-Partition -AssignDriveLetter "3" -UseMaximumSize |
Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “USERDB” -Confirm:$false
New-Partition -AssignDriveLetter "4" -UseMaximumSize |
Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “LOGDB” -Confirm:$false
New-Partition -AssignDriveLetter "5" -UseMaximumSize |
Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel “TEMPDB” -Confirm:$false
}
#####################################################################################
SQL_Disk

#------------------------ Set in the Release inline script ------------------------
#az account set --subscription "$(sub)"
#
#Select-AzSubscription -Subscription 7fa3c3a2-7d0d-4987-a30c-30623e38756c
#
#$virtualmachine = Get-AzVm -Name $(vm) -ResourceGroupName $(rg)
#
#$datadisk = $virtualmachine.StorageProfile.DataDisks.Name
#
#az vm stop --resource-group $(rg) --name $(vm)
#
#az vm deallocate -g $(rg) -n $(vm)
#
#az vm disk detach -g $(rg) --vm-name $(vm) --name $datadisk
#
#Remove-AzDisk -ResourceGroupName $(rg) -DiskName $datadisk -Force
#
##disk_0
#az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_0  --size-gb $(disk_0) --sku Standard_LRS --caching ReadOnly  --new
#
##disk_1
#az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_1  --size-gb $(disk_1) --sku Standard_LRS --caching ReadOnly --new
#
##disk_2
#az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_2  --size-gb $(disk_2) --sku Standard_LRS --caching None --new
#
##disk_3
#az vm disk attach --resource-group $(rg) --vm-name $(vm) --name $(vm)_datadisk_3  --size-gb $(disk_3) --sku Standard_LRS --caching ReadOnly --new
#
#az vm start -g $(rg) -n $(vm)