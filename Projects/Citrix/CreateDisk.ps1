$osDiskName = 'gen2Diskfrmgenvhd'
$location = "North Europe"
$rg = "rg-shh-prod-applicationcitrix-01"
$sourceUri = "https://stprodgeneric0001.blob.core.windows.net/citrix/abcd.vhd"
$diskconfig = New-AzDiskConfig -Location $location -DiskSizeGB 127 -AccountType Standard_LRS -OsType Windows -HyperVGeneration "V2" -SourceUri $sourceUri -CreateOption 'Import' -StorageAccountId "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-cis-prod-storage-01/providers/Microsoft.Storage/storageAccounts/stprodgeneric0001"
New-AzDisk -DiskName $osDiskName -ResourceGroupName $rg -Disk $diskconfig