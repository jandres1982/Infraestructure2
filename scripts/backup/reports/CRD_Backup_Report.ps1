$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-[aec][upmh]*"}
#$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01")
$date = $(get-date -format yyyy-MM-ddTHH-mm)
$kg = "CRD"
$sum = "*$kg" + "wsr*"
###################################################################

foreach ($sub in $subs)
{

Select-AzSubscription -Subscription "$sub"

$Vault_List = (Get-AzRecoveryServicesVault).Name 
foreach ($vault in $Vault_List) 
{ 
$Vault_ResourecGroup = (Get-AzRecoveryServicesVault -Name $vault).ResourceGroupName 
#$Vault_ResourecGroup = "rg-cis-prod-backup-01" 
#$vault = "rsv-prod-euno-lrsbackup-01" 
$Vault_ID = Get-AzRecoveryServicesVault -ResourceGroupName "$Vault_ResourecGroup" -Name $vault 
$Jobs = Get-AzRecoveryServicesBackupJob -VaultId $Vault_ID.Id -WarningAction SilentlyContinue | where-object {$_.WorkLoadname -like "$sum"}
#$JobDetails = Get-AzRecoveryServicesBackupJobDetail -Job $Jobs[0] -VaultId $vault_ID.ID | Export-Csv -Path "Backup_Report_CRD_Prod_$date.csv"  -Append 
$Jobs | Export-Csv -Path "Backup_Report_$kg_$date.csv" -Append -Force 
}

}

$PSEmailServer = "smtp.eu.schindler.com"
$From = "scc-support-zar.es@schindler.com"
$to = "alfonso.marques@schindler.com","antoniovicente.vento@schindler.com"

$Subject = "Backup Report $kg Servers"
#$Filename = Get-ChildItem $Path -Name "Att*" | select -Last 1
$Attachment = "Backup_Report_$kg_$date.csv"
$Body = @"
Dear team,

Please find attached the Report for $kg Backup Jobs.

Best regards,

Schindler Server Team - Devops Automated Report
"@

Send-MailMessage -From $From -To $To -Subject $Subject -Body $Body -Attachments $Attachment

#Copy-Item -Path $Attachment -Destination \\shhwsr1849\Backup_Report_Azure -Force