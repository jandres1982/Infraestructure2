$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
#$subs= "s-sis-eu-nonprod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)

###################################################################

$vmBackupReport = [System.Collections.ArrayList]::new()

foreach ($sub in $subs)
{

    Write-Host "Collecting all Backup Recovery Vault information in $sub" -BackgroundColor DarkGreen

Select-AzSubscription -Subscription "$sub"
az account set --subscription "$sub"

#$Vault_List = (Get-AzRecoveryServicesVault).Name
#foreach ($vault in $Vault_List) 
#{ 
#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$backupVaults = Get-AzRecoveryServicesVault
$vms = get-azvm

 foreach ($vm in $vms) 
 {
     $recoveryVaultInfo = Get-AzRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type 'AzureVM' -WarningAction SilentlyContinue
     if ($recoveryVaultInfo.BackedUp -eq $true)
     {
         Write-Host "$($vm.Name) - BackedUp : Yes"
         #Backup Recovery Vault Information
         $vmBackupVault = $backupVaults | Where-Object {$_.ID -eq $recoveryVaultInfo.VaultId}

         #Backup recovery Vault policy Information
         $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vmBackupVault.ID -FriendlyName $vm.Name -WarningAction SilentlyContinue -Status "Registered"
         if ($container.Count -gt 1)
         {$backupItem = Get-AzRecoveryServicesBackupItem -Container $container[1] -WorkloadType AzureVM -VaultId $vmBackupVault.ID -WarningAction SilentlyContinue}
         else
         {
         $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vmBackupVault.ID -WarningAction SilentlyContinue
         }
     } #if ($recoveryVaultInfo.BackedUp -eq $true)
     else 
     {
         Write-Host "$($vm.Name) - BackedUp : No" -BackgroundColor DarkRed
         $vmBackupVault = $null
         $container =  $null
         $backupItem =  $null
     } #else if ($recoveryVaultInfo.BackedUp -eq $true)


      [void]$vmBackupReport.Add([PSCustomObject]@{
         VM_Name = $vm.Name
         VM_Location = $vm.Location
         VM_ResourceGroupName = $vm.ResourceGroupName
         VM_BackedUp = $recoveryVaultInfo.BackedUp
         VM_RecoveryVaultName =  $vmBackupVault.Name
         VM_RecoveryVaultPolicy = $backupItem.ProtectionPolicyName
         VM_BackupHealthStatus = $backupItem.HealthStatus
         VM_BackupProtectionStatus = $backupItem.ProtectionStatus
         VM_LastBackupStatus = $backupItem.LastBackupStatus
         VM_LastBackupTime = $backupItem.LastBackupTime
         VM_BackupDeleteState = $backupItem.DeleteState
         VM_BackupLatestRecoveryPoint = $backupItem.LatestRecoveryPoint
         VM_Id = $vm.Id
         RecoveryVault_ResourceGroupName = $vmBackupVault.ResourceGroupName
         RecoveryVault_Location = $vmBackupVault.Location
         RecoveryVault_SubscriptionId = $vmBackupVault.ID
     }) #[void]$vmBackupReport.Add([PSCustomObject]@{
 } #foreach ($vm in $vms) 
}
#}
$vmBackupReport | Export-Csv Backup_ESP_POR_Report_$date.csv

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com","nahum.sancho@schindler.com"

$Subject = "Backup_Report_All_Info"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = "Backup_Report_All_Info_$date.csv"
$Body = @"
Dear team,

Please find attached the Report for Backup for all VMs in Azure.

Best regards,

Schindler Server Team - DevOps Automated Report
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment