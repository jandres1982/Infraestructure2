$sub="s-sis-eu-prod-01"
$virtualmachine="shhwsr1848"
$retentiondate="24-08-2022"

###Set Subsciption###
set-azcontext -subscription $sub

###VM Variables###
$vm = Get-AzVM -name $virtualmachine


###Backup Variables###
$status = Get-azRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type "AzureVM"
$vault = $status.VaultId.Split('/')[-1]
$vaultid = $status.Vaultid
$vaultrg = $status.VaultId.Split('/')[-5]

###Backup Job##
Write-Host "The VM $vm.Name is member of vault $vault"
az backup protection backup-now --vault-name $vault --backup-management-type "AzureIaasVM" --container-name $vm.Name --item-name $vm.Name --resource-group $vaultrg --retain-until $retentiondate