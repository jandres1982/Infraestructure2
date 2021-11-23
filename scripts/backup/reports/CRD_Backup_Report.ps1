Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$Vault_List = (Get-AzRecoveryServicesVault).Name 
foreach ($vault in $Vault_List) 
{ 
$Vault_ResourecGroup = (Get-AzRecoveryServicesVault -Name $vault).ResourceGroupName 
#$Vault_ResourecGroup = "rg-cis-prod-backup-01" 
#$vault = "rsv-prod-euno-lrsbackup-01" 
$Vault_ID = Get-AzRecoveryServicesVault -ResourceGroupName "$Vault_ResourecGroup" -Name $vault 
$Jobs = Get-AzRecoveryServicesBackupJob -VaultId $Vault_ID.Id | where-object {$_.WorkLoadname -like "*crdwsr*"}
#$JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault_ID.ID | Export-Csv -Path "Backup_Report_CRD_Prod_$date.csv"  -Append 
$Jobs | Export-Csv -Path "Backup_Report_CRD_Prod_$date.csv" -Append -Force 
} 


$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "antoniovicente.vento@schindler.com","alfonso.marques@schindler.com"

$Subject = "Backup Report CRD Prod Subscription"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = "Backup_Report_CRD_Prod_$date.csv"
$Body = @"
Dear team,

Please find attached the Report for CRD Backup Jobs.

Report saved in the Server Team Scripting Server

"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

Copy-Item -Path $Attachment -Destination \\shhwsr1849\Backup_Report_Azure -Force