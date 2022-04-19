## Variables
#$sub = "s-sis-eu-nonprod-01"
#$vm = "zzzwsr0010"
#$rgvault = "rg-cis-nonprod-backup-01" 
#$vaultName = "rsv-nonprod-euno-lrsbackup-01" 
#$new_vault = "rsv-nonprod-euno-lrsbackup-02"
#$new_rg_vault = "rg-cis-nonprod-backup-01"
#$policy = "vm-short-01am-01"

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Select subscription and Backup Vault

Set-AzContext -Subscription $(sub)
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $rgBackup -Name $(vaultName)

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Disable soft delete for the Azure Backup Recovery Services vault

Set-AzRecoveryServicesVaultProperty -Vault $vault.ID -SoftDeleteFeatureState Disable
Write-Host ($writeEmptyLine + " # Soft delete disabled for Recovery Service vault " + $vault.Name)

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Stop protection and delete data for all backup-protected items

$Container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName $(vm) -VaultId $vault.ID
$BackupItem = Get-AzRecoveryServicesBackupItem -Container $Container -WorkloadType AzureVM -VaultId $vault.ID
Disable-AzRecoveryServicesBackupProtection -Item $BackupItem -VaultId $vault.ID -RemoveRecoveryPoints -Force -Verbose
Write-Host ($writeEmptyLine + "# Deleted backup date for $vm in Recovery Services vault ")

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Enable soft delete for the Azure Backup Recovery Services vault

Set-AzRecoveryServicesVaultProperty -Vault $vault.ID -SoftDeleteFeatureState Enable
Write-Host ($writeEmptyLine + " # Soft delete enabled for Recovery Service vault " + $vault.Name)

## ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
## Start protection VM on a different Backup Vault

$new_vault = Get-AzRecoveryServicesVault -ResourceGroupName $(new_rg_vault) -Name $(new_vault)
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $new_vault.ID -Name $(policy)
$virtualmachine = Get-AzVM -Name $vm
Enable-AzRecoveryServicesBackupProtection -VaultId $new_vault.ID -Policy $policy -name $virtualmachine.Name -ResourceGroupName $virtualmachine.ResourceGroupName

Write-Host ($writeEmptyLine + " # Backup enable for $vm in Recovery Service vault" + $new_vault.Name)