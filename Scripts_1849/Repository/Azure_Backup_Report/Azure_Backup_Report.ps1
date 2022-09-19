$Vault_List = (Get-AzRecoveryServicesVault).Name


foreach ($vault in $Vault_List)
{

$Vault_ResourecGroup = (Get-AzRecoveryServicesVault -Name $vault).ResourceGroupName


#$Vault_ResourecGroup = "rg-cis-prod-backup-01"
#$vault = "rsv-prod-euno-lrsbackup-01"

$Vault_ID = Get-AzRecoveryServicesVault -ResourceGroupName "$Vault_ResourecGroup" -Name $vault

$Jobs = Get-AzRecoveryServicesBackupJob -VaultId $Vault_ID.Id
#$JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault_ID.ID | Export-Csv -Path "D:\Repository\Working\Antonio\Azure_Backup_Report\Azure_Backup_Report_Details.csv" -Append
$Jobs | Export-Csv -Path "D:\Repository\Working\Antonio\Azure_Backup_Report\Azure_Backup_Report.csv" -Append -Force
}