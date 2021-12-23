$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")
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
$Jobs = Get-AzRecoveryServicesBackupJob -VaultId $Vault_ID.Id -BackupManagementType AzureVM | where-object {$_.WorkLoadname -like "*wsr*"}
#$JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault_ID.ID | Export-Csv -Path "Backup_Report_CRD_Prod_$date.csv"  -Append 
$Jobs | Export-Csv -Path "Backup_Report_WSR_$date.csv" -Append -Force 

$Jobs_failed = Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-7).ToUniversalTime() -Status Failed -VaultId $Vault_ID.id
$Jobs_failed | Export-Csv -Path "Backup_Report_WSR_$date_FAILED.csv" -Append -Force

}



}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com","alfonso.marques@schindler.com","alberto.delgado@schindler.com"

$Subject = "Backup Report for All WSR named Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = (get-childitem "*.csv")
$Body = @"
Dear team,

Please find attached the Report for Backup Jobs in Azure for WSR named Servers.

Report saved in the Server Team Scripting Server

"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Copy-Item -Path $Attachment -Destination \\shhwsr1849\Backup_Report_Azure -Force

