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

$destination_vault = Get-AzRecoveryServicesVault -ResourceGroupName $(new_rg_vault) -Name $(new_vault)
$policyname = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $destination_vault.ID -Name $(policy)
$virtualmachine = Get-AzVM -Name $(vm)
Enable-AzRecoveryServicesBackupProtection -VaultId $destination_vault.ID -Policy $policyname -name $virtualmachine.Name -ResourceGroupName $virtualmachine.ResourceGroupName

Write-Host ($writeEmptyLine + " # Backup enable for $vm in Recovery Service vault" + $destination_vault.Name)