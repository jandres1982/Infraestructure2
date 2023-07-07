param([string]$sub, [string]$BackupPolicy, [string]$vm)

switch ($sub) {
    "s-sis-eu-prod-01" {
        $rsv = "rsv-prod-euno-zrsbackup-01"
        $backupRg = "rg-cis-prod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        if ($BackupPolicy -eq "vm-short-01am-01") {
            $BackupPolicy = "vm-short-01am-02"
        }
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-eu-nonprod-01" {
        $rsv = "rsv-nonprod-euno-zrsbackup-01"
        $backupRg = "rg-cis-nonprod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-ap-prod-01" {
        $rsv = "rsv-prod-asse-zrsbackup-01"
        $backupRg = "rg-cis-prod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-am-prod-01" {
        $rsv = "rsv-prod-use2-zrsbackup-01"
        $backupRg = "rg-cis-prod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-am-nonprod-01" {
        $rsv = "rsv-nonprod-use2-zrsbackup-01"
        $backupRg = "rg-cis-nonprod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-ch-nonprod-01" {
        $rsv = "rsv-nonprod-chno-zrsbackup-01"
        $backupRg = "rg-cis-nonprod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName

    }

    "s-sis-ch-prod-01" {
        $rsv = "rsv-prod-chno-zrsbackup-01"
        $backupRg = "rg-cis-prod-backup-01"
        Select-AzSubscription -Subscription $sub
        $vault = Get-AzRecoveryServicesVault -ResourceGroupName $backupRg -Name $rsv
        $policy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $vault.id -Name $BackupPolicy
        $vmProfile = Get-AzVM -Name $vm
        Enable-AzRecoveryServicesBackupProtection -VaultId $vault.ID -Policy $policy -name $vmProfile.Name -ResourceGroupName $vmProfile.ResourceGroupName
 
    }
}