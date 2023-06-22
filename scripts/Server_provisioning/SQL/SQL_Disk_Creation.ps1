$rg = "rg-cis-test-server-01"
$vm  = "zzzwsr0012"
$virtualmachine  = az vm show -g $rg -n $vm
$vmprofile = $virtualmachine | ConvertFrom-Json
$datadisk = $vmprofile.storageProfile.dataDisks.name
az vm stop --resource-group $rg --name $vm
az vm deallocate -g $rg -n $vm
az vm disk detach -g $rg --vm-name $vm --name $datadisk
az disk delete -n $datadisk -g $rg -y
#Remove-AzDisk -ResourceGroupName $(rg) -DiskName $datadisk -Force