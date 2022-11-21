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

$vm= "shhwsr1848"
$sub = "s-sis-eu-prod-01"

#Name ---> "Snapshots_Schedule"
Write-Output "$vm"
Write-Output "$Sub"
Write-Output "$Retention"
Write-Output "$Schedule_Time"

#$Conn = Get-AutomationConnection -Name AzureRunAsConnection
#Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

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
$Backup = Backup-AzRecoveryServicesBackupItem -Item $item
# -ExpiryDateTimeUTC $Schedule_Time.AddDays($Retention)

$Job = Get-AzRecoveryServicesBackupJob -VaultId $vaultid -Jobid $Backup.JobId

while ($job.Status -eq "InProgress")
{

    Write-Output "Backup is in progress"
    Start-Sleep 1000
    $Job = Get-AzRecoveryServicesBackupJob -VaultId $vaultid -Jobid $Backup.JobId

}




$resourceGroup = "resourceGroup"
$vaultName = "vaultName"

$jobs = az backup job list --resource-group $resourceGroup --vault-name $vaultName --start-date 28-8-2020 | convertfrom-json
$jobName = $jobs[0].name

$jobStatus = az backup job show --name $jobName --resource-group $resourceGroup --vault-name $vaultName
$taskStatus = $jobStatus.properties.extendedInfo.tasksList | Where-Object { $_.taskId -eq "Take Snapshot"}
While ( $taskStatus.status -ne Completed ) {
     Write-Host -Object "Waiting for completion..."
     Start-Sleep -minutes 1
     $jobStatus = az backup job show --name $jobName --resource-group $resourceGroup --vault-name $vaultName
     $taskStatus = $jobStatus.properties.extendedInfo.tasksList | Where-Object { $_.taskId -eq "Take Snapshot"}
}
Write-Host -Object "Done!"












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