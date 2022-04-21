$sub = "s-sis-eu-prod-01"
$vm = "shhwsr2313"
$new_rg_vault = "rg-cis-prod-backup-01"
$new_vault = "rsv-prod-euno-lrsbackup-02"

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Select subscription and Backup Vault

Set-AzContext -Subscription $sub
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $new_rg_vault -Name $new_vault
Set-AzRecoveryServicesVaultContext -Vault $vault

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Run first backup job

$backupcontainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM"  -FriendlyName $vm
$item = Get-AzRecoveryServicesBackupItem -Container $backupcontainer -WorkloadType "AzureVM"
Backup-AzRecoveryServicesBackupItem -Item $item