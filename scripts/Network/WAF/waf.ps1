#waf
#config
$sub = "s-sis-eu-prod-01"
$rg = "RG_NETWORK_PROD"
$policy = "3dexcite"

#Select-AzSubscription -Subscription $sub
#$AppGW = Get-AzApplicationGateway -Name "agw-prod-network-shhnag0001" -ResourceGroupName "RG_NETWORK_PROD"
#$FirewallConfig = Get-AzApplicationGatewayWebApplicationFirewallConfiguration -ApplicationGateway $AppGW

#az login
az account set --subscription $sub
$Policy_Waf_Config = az network application-gateway waf-policy managed-rule rule-set list --policy-name $policy --resource-group $rg
$Pol = $Policy_Waf_Config | ConvertFrom-Json

#$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
$subs = "s-sis-eu-prod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)
###################################################################

$wafPolicyReport = [System.Collections.ArrayList]::new()

foreach ($sub in $subs)
{
    az account set --subscription $sub
    Write-Host "Collecting WAf Policy Rules $sub" -BackgroundColor DarkGreen
    Select-AzSubscription -Subscription $sub
    $wafPol = az network application-gateway waf-policy list | convertfrom-json


    foreach ($waf in $wafPol)
    {
        $wafRg = $waf.resourceGroup
        $wafPolicyName = $waf.Name
        $wafPolRule = az network application-gateway waf-policy managed-rule rule-set list --policy-name $wafPolicyName --resource-group $wafRg | convertfrom-json
        $wafPolRuleSetType = $wafpolrule.managedRuleSets.rulesettype
            foreach ($rule in $wafPolRule)
            {
                $RuleSetType = $rule.managedRuleSets.rulesettype
                $ruleSetVersion = $rule.ruleSetVersion

                [void]$wafPolicyReport.Add([PSCustomObject]@{
                    WAF = $wafPolicyName
                    WAF_RG = $wafRg
                    WAF_Location = $waf.Location
                    WAF_Sub = $sub
                    RuleSetType = $RuleSetType
                    ruleSetVersion =  $ruleSetVersion
            }
        }

    }

            $report = 'Backup_'+"$kg"+'_Report_'+"$date"+'.csv'
            $vmBackupReport | Export-Csv $report -NoTypeInformation | Select-Object -Skip 1 | Set-Content $Report








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


