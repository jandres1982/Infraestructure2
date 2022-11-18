###VM Variables###
$vm = Get-AzVM -name $(virtualmachine)
$rg = $vm.ResourceGroupName
$vmname = $vm.Name

###Backup Variables###
$status = Get-azRecoveryServicesBackupStatus -Name $vmname -ResourceGroupName $rg -Type "AzureVM"
$vault = $status.VaultId.Split('/')[-1]
$vaultid = $status.Vaultid
$vaultrg = $status.VaultId.Split('/')[-5]

###Backup Job###
Write-Host "The VM $vmname is member of vault $vault"
az backup protection backup-now --vault-name $vault --backup-management-type "AzureIaasVM" --container-name $vmname --item-name $vmname --resource-group $vaultrg --retain-until $(retentiondate)