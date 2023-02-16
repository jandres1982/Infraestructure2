$sub="s-sis-eu-nonprod-01"
$virtualmachine="zzzwsr0010"
$retentiondate="30-08-2022"


###Set Subsciption###
set-azcontext -subscription $sub
az account set --subscription $sub

###VM Variables###
$vms=Get-AzVM
$vm=$vms | where-object {$_.Name -eq "$virtualmachine"}



###Backup Variables###
$status = Get-azRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type "AzureVM"
$vault = $status.VaultId.Split('/')[-1]
$vaultid = $status.Vaultid
$vaultrg = $status.VaultId.Split('/')[-5]

###Backup Job##
Write-Host "The VM $vm.Name is member of vault $vault"
az backup protection backup-now --vault-name $vault --backup-management-type "AzureIaasVM" --container-name $vm.Name --item-name $vm.Name --resource-group $vaultrg --retain-until $retentiondate