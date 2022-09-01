param (
[Parameter(Mandatory = $false)]
[string]$vm,
[Parameter(Mandatory = $false)]
[string]$sub,
[Parameter(Mandatory = $false)]
[int]$Retention,
[Parameter(Mandatory = $false)]
[datetime]$Schedule_Time
)
#Name ---> "Snapshots_Schedule"
Write-Output "$vm"
Write-Output "$Sub"
Write-Output "$Retention"
Write-Output "$Schedule_Time"

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

##################  Create a runbook with this data ##############################

select-azsubscription -subscription $sub
set-azcontext -subscription $sub

$Virtual_Machine = Get-AzVm | where-object {$_.Name -eq "$vm"}

###Backup Variables###
$status = Get-azRecoveryServicesBackupStatus -Name $Virtual_Machine.Name -ResourceGroupName $Virtual_Machine.ResourceGroupName -Type "AzureVM"
$vault = $status.VaultId.Split('/')[-1]
$vaultid = $status.Vaultid
$vaultrg = $status.VaultId.Split('/')[-5]

$vault = Get-AzRecoveryServicesVault -ResourceGroupName $vaultrg -Name $vault
Set-AzRecoveryServicesVaultContext -Vault $vault

$backupcontainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM"  -FriendlyName $Virtual_Machine.name
$item = Get-AzRecoveryServicesBackupItem -Container $backupcontainer -WorkloadType "AzureVM"
Backup-AzRecoveryServicesBackupItem -Item $item -ExpiryDateTimeUTC $Schedule_Time.AddDays($Retention)



#if ($WebhookData) {
#    Write-Output "The Webhook Header"
#    Write-Output $WebhookData.RequestHeader.Message
#    Write-Output "The Webhook Name"
#    Write-Output $WebhookData.WebhookName
#	Write-Output "The Webhook Body"
#	Write-Output $WebhookData.RequestBody
#	}
#	else {
#   Write-Output "No Data Received"
#    }

#$var = $WebhookData.RequestBody
#$vm = $var.split(" ")[0]
#$sub = $var.split(" ")[1]
#$Retain = $var.split(" ")[2]
#$schedule_set = $var.split(" ")[3]

###Set Subsciption###