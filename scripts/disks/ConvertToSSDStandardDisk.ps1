




#select sub
Select-AzSubscription -Subscription $(sub)
Set-AzContext -subscription $(sub)
az account set --subscription $(sub)

#main
az vm stop --resource-group $(rg) --name $(vm)
az vm deallocate -g $(rg) -n $(vm)

#---Define VM
$virtualmachine = Get-AzVm -Name $(vm) -ResourceGroupName $(rg)

#--- OSDisk
$osdisk = $virtualmachine.StorageProfile.OSDisk.Name
az disk update -g $(rg) -n $osdisk --sku StandardSSD_LRS

#---- DataDisks
$datadisk = $virtualmachine.StorageProfile.DataDisks.Name
foreach ($disk in $datadisk)
{
az disk update -g $(rg) -n $disk --sku StandardSSD_LRS
}

az vm start -g $(rg) -n $(vm)