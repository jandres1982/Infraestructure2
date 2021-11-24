
$today = get-date -Format ("MM-dd-yyyy")
$oFile = "C:\Users\ventoa1\OneDrive - Schindler\Azure_Devops\Infraestructure\scripts\backup\reports\Backup_Status_$($today).csv"
"VirtualMachine, VM Status, Vault Name, Vault Resource Group,  Protection Status, Protection State, Last Backup Status,Last Backup Date, Policy Name, Container Type, Container Name "  |  Out-File $oFile -Append -Encoding ASCII




Get-AzRecoveryServicesVault | ForEach-Object{
    $vault = $_.Name
    $vaultResourceGroup = $_.ResourceGroupName
    Set-AzRecoveryServicesVaultContext -Vault $_
        Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM | ForEach-Object{
            Get-AzRecoveryServicesBackupItem -Container $_ -WorkloadType AzureVM


}

$vault = Get-AzRecoveryServicesVault -Name "rsv-prod-euno-lrsbackup-01"
Set-AzRecoveryServicesVaultContext -Vault $vault
Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM | ForEach-Object {
$Protected_VM = Get-AzRecoveryServicesBackupItem -Container $_ -WorkloadType AzureVM
$Protected_VM.name
$Protected_VM.ProtectionStatus
$Protected_VM.HealthStatus
$Protected_VM.ContainerUniqueName

}


#$Vault_ResourecGroup = "rg-cis-prod-backup-01" 
#$vault = "rsv-prod-euno-lrsbackup-01" 