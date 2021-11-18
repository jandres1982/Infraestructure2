$Vault = Get-AzureRmBackupVault -Name "rsv-nonprod-chno-lrsbackup-01"
$Daily = New-AzureRmBackupRetentionPolicyObject -DailyRetention -Retention 30
$ProtectionPolicy = New-AzureRmBackupProtectionPolicy -Name "vm-short-01am-01" -Type AzureVM -Daily -BackupTime ([datetime]"1:00 AM") -RetentionPolicy ($Daily) -Vault $Vault