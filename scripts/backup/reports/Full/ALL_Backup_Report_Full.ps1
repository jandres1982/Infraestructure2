#$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$kg = "ALL"
###################################################################

$vmBackupReport = [System.Collections.ArrayList]::new()

foreach ($sub in $subs)
{

    Write-Host "Collecting all Backup Recovery Vault information in $sub" -BackgroundColor DarkGreen

Select-AzSubscription -Subscription "$sub"

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
         $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vmBackupVault.ID -FriendlyName $vm.Name -WarningAction SilentlyContinue
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
$report = 'Backup_'+"$kg"+'_Report_'+"$date"+'.csv'
$vmBackupReport | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "gda_usr_dcff050b-8326-48c9-8bf9-61f8de7e89f0@schindler.com","gdl_usr_7aabcc1e-97e6-4283-9271-c04245556940@cloud.schindler.com"

$Subject = "Backup Report $kg Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = $report
$Body = @"
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Dear team,</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Please find attached the Report for $kg Backup VM's.</span></div>
<div>&nbsp;</div>
<div><span style="font-size: medium; font-family: arial, helvetica, sans-serif;">Best regards,</span></div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div><span>&nbsp; &nbsp; </span></div>
<div><span style="font-size: small; font-family: arial, helvetica, sans-serif;"><strong>Backup Policies Resumed Information</strong></span></div>
<div>
<ul>
<li><span style="font-size: small; font-family: arial, helvetica, sans-serif;">Short - vm snapshot daily at 1:00AM and 30 days retention</span></li>
</ul>
</div>
<div>
<ul>
<li><span style="font-size: small; font-family: arial, helvetica, sans-serif;">Medium - same as short plus weekly Sunday at 1:00AM and 12 weeks retention</span></li>
</ul>
</div>
<div>
<ul>
<li><span style="font-size: small; font-family: arial, helvetica, sans-serif;">Long - same as medium plus monthly 1st day of the month at 1:00AM and 12 months retention</span></li>
</ul>
<p>&nbsp;</p>
<p><span style="font-size: medium; font-family: arial, helvetica, sans-serif; color: #ff0000;">Schindler Server Team - DevOps Automated Report</span></p>
<p>&nbsp;</p>
</div>
<div>&nbsp;</div>
"@
#https://htmled.it/

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -BodyAsHtml