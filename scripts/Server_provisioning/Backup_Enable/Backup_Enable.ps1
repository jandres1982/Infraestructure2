#$sub = "s-sis-eu-nonprod-01"
#$Backup_rg = "rg-cis-nonprod-backup-01"
#$Vault = "rsv-nonprod-euno-lrsbackup-01"
#$policy = "vm-medium-01am-01"
#$vm = "zzzwsr0026"
Select-AzSubscription -Subscription $sub
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $Backup_rg -Name $Vault
$policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $Vault.ID -Name $policy
$vm = Get-AzVM -Name $vm
Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $VM.Name -ResourceGroupName $vm.ResourceGroupName