#$subs = Get-AzSubscription | Where-Object {($_.Name -match "s-sis-eu-prod-01") -or ($_.Name -match "s-sis-eu-nonprod-01")}
$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
#$subs= "s-sis-eu-nonprod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$kg = "CRD"
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
$vms = get-azvm | where-object {$_.Name -like "$kg*"}

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
                $backupItem = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType AzureVM -VaultId $vmBackupVault.ID -WarningAction SilentlyContinue

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
$to = "alfonso.marques@schindler.com","antoniovicente.vento@schindler.com"


$Subject = "Backup Report $kg Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = $report
$Body = @"
<div>Dear team,</div>
<div>
<div aria-hidden="true">&nbsp;</div>
<div><span>Please find attached the Backup Report for $kg</span></div>
<div aria-hidden="true">&nbsp;</div>
<div><span>Best regards,</span></div>
<div aria-hidden="true">&nbsp;</div>
</div>
<div><span style="text-decoration: underline;">Useful information related to backup policy</span>:</div>
<div><span style="font-size: large;"><b></b></span></div>
<div><span style="font-size: large;"><b>Short term Backup:</b></span></div>
<div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1550" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: backupFrequencyLabel">Backup Frequency</div>
<div data-bind="text: backupFrequencyText">Daily at 12:00 AM UTC</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1551" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: instantRestoreLabel">Instant Restore</div>
<div data-bind="text: instantRestoreText">Retain instant recovery snapshot(s) for 5 day(s)</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1552" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div data-bind="visible: isDailyLTREnabled">
<div data-bind="text: dailyLTRLabel">Retention of daily backup point</div>
<div data-bind="text: dailyLTRText">Retain backup taken every day at 12:00 AM for 30 Day(s)<span style="font-size: xx-large;"></span></div>
<div data-bind="text: dailyLTRText"></div>
<div data-bind="text: dailyLTRText"><span style="font-size: large;"><b>Medium term Backup:</b></span></div>
<div data-bind="text: dailyLTRText">
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1555" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: backupFrequencyLabel">Backup Frequency</div>
<div data-bind="text: backupFrequencyText">Daily at 12:00 AM UTC</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1556" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: instantRestoreLabel">Instant Restore</div>
<div data-bind="text: instantRestoreText">Retain instant recovery snapshot(s) for 5 day(s)</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1557" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div data-bind="visible: isDailyLTREnabled">
<div data-bind="text: dailyLTRLabel">Retention of daily backup point</div>
<div data-bind="text: dailyLTRText">Retain backup taken every day at 12:00 AM for 30 Day(s)</div>
</div>
<div data-bind="visible: isWeeklyLTREnabled">
<div data-bind="text: weeklyLTRLabel">Retention of weekly backup point</div>
<div data-bind="text: weeklyLTRLabel"></div>
<div data-bind="text: weeklyLTRText">Retain backup taken every week on Sunday at 12:00 AM for 12 Week(s)</div>
<div data-bind="text: weeklyLTRText"></div>
<div data-bind="text: weeklyLTRText"><b><span style="font-size: large;">Long Term Backup:</span></b></div>
<div data-bind="text: weeklyLTRText">
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1565" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: backupFrequencyLabel">Backup Frequency</div>
<div data-bind="text: backupFrequencyText">Daily at 12:00 AM UTC</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1566" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div>
<div data-bind="text: instantRestoreLabel">Instant Restore</div>
<div data-bind="text: instantRestoreText">Retain instant recovery snapshot(s) for 5 day(s)</div>
</div>
</div>
<label class="azc-text-sublabel msportalfx-tooltip-overflow" data-bind="untrustedContentDeprecated: $data" aria-hidden="true"></label></div>
</div>
<div class="fxc-weave-pccontrol fxc-section-control fxc-base msportalfx-customHtml msportalfx-form-formelement" data-bind="pcControl: __control_vm__" id="_weave_e_1567" data-formelement="pcControl: __control_vm__">
<div class="azc-formElementSubLabelContainer">
<div class="azc-formElementContainer" data-bind="untrustedHtml: { html: htmlTemplate, data: innerViewModel, isolated: isolated }">
<div data-bind="visible: isDailyLTREnabled">
<div data-bind="text: dailyLTRLabel">Retention of daily backup point</div>
<div data-bind="text: dailyLTRText">Retain backup taken every day at 12:00 AM for 30 Day(s)</div>
</div>
<div data-bind="visible: isWeeklyLTREnabled">
<div data-bind="text: weeklyLTRLabel">Retention of weekly backup point</div>
<div data-bind="text: weeklyLTRText">Retain backup taken every week on Sunday at 12:00 AM for 12 Week(s)</div>
<div data-bind="text: weeklyLTRText"></div>
</div>
<div data-bind="visible: isMonthlyLTREnabled">
<div data-bind="text: monthlyLTRLabel">Retention of monthly backup point</div>
<div data-bind="text: monthlyLTRText">Retain backup taken every month on 1 at 12:00 AM for 12 Month(s)</div>
<div data-bind="text: monthlyLTRText"></div>
<div data-bind="text: monthlyLTRText"></div>
<div data-bind="text: monthlyLTRText"></div>
<span data-bind="text: monthlyLTRText" style="color: #0000ff;"><span>Schindler SCC - Automated Azure Report</span></span></div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment -BodyAsHtml