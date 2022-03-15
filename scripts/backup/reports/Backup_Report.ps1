$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
$date = $(get-date -format yyyy-MM-ddTHH-mm)

###################################################################

foreach ($sub in $subs)
{

Select-AzSubscription -Subscription "$sub"
az account set --subscription "$sub"

$Vault_List = (Get-AzRecoveryServicesVault).Name 
foreach ($vault in $Vault_List) 
{ 
$Vault_ResourecGroup = (Get-AzRecoveryServicesVault -Name $vault).ResourceGroupName 
#$Vault_ResourecGroup = "rg-cis-prod-backup-01" 
#$vault = "rsv-prod-euno-lrsbackup-01" 
$Vault_ID = Get-AzRecoveryServicesVault -ResourceGroupName "$Vault_ResourecGroup" -Name $vault
$Jobs = Get-AzRecoveryServicesBackupJob -VaultId $Vault_ID.Id -BackupManagementType AzureVM
#$JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault_ID.ID | Export-Csv -Path "Backup_Report_CRD_Prod_$date.csv"  -Append 
$Jobs | Export-Csv -Path "vm_backup_report_all.csv" -Append -Force 

$Jobs_failed = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-3).ToUniversalTime() -Status Failed -VaultId $Vault_ID.id |  Sort-Object -Property @{Expression={$_.WorkloadName}} -Unique
$Jobs_failed | Export-Csv -Path "vm_backup_failed.csv" -Append -Force

}

$vms = $(Get-AzVM).name
foreach ($vm in $vms)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
$backup = $(Get-AzRecoveryServicesBackupStatus -Name $vm -ResourceGroupName $rg -Type AzureVM).BackedUp
if ($backup -eq $false)
{
    Write-Output "$vm,$rg,$sub" >> "vm_no_backup.csv"
}else {
    Write-Host "$vm Backup should be ok"
}
}
}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "gda_usr_dcff050b-8326-48c9-8bf9-61f8de7e89f0@schindler.com","gdl_usr_7aabcc1e-97e6-4283-9271-c04245556940@cloud.schindler.com"

$Subject = "Backup Report for All Azure Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = (get-childitem "*.csv")
$Body = @"
Dear team,

Please find attached the Report for Backup Jobs for Azure Servers.

Best regards,
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

#Copy-Item -Path $Attachment -Destination \\shhwsr1849\Backup_Report_Azure -Force



#if (Get-AzRecoveryServicesBackupStatus -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Type 'AzureVM' -Verbose)
#{Write-Host "VM is included in a VAULT"
#}else
#{Write-Host "Check the $VM"
#}

