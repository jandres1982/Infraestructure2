##Variables
$sub = "s-sis-eu-nonprod-01"
$vm = "zzzwsr0010"
$RSV = "rsv-nonprod-euno-lrsbackup-02"
$RSV_RG = "rg-cis-nonprod-backup-01"

##
Select-AzSubscription -Subscription $SUB
##
#Stop_Backup_Protection
$vault = Get-AzRecoveryServicesVault -ResourceGroupName $RSV_RG -Name $RSV
Set-AzRecoveryServicesVaultContext -Vault $vault
$Cont = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered | Where-Object {$_.FriendlyName -eq $VM}
$PI = Get-AzRecoveryServicesBackupItem -Container $Cont[0] -WorkloadType AzureVM
Disable-AzRecoveryServicesBackupProtection -Item $PI[0] -force

#Create_RG
$location = "northeurope"
$Virtual_Machine =  get-azvm -name $vm
$vm_rg = $Virtual_Machine.ResourceGroupName
$Old_rg = get-azresourceGroup -name $VM_RG
$tags = $Old_rg.tags
$Number = $VM_RG.Substring($($VM_RG.Length-2))
$add = [int]$Number += 1
$New_number = "0"+[string]$add
$New_rg = $($old_rg.ResourceGroupName.Remove($old_rg.ResourceGroupName.Length-2))+$New_number
New-AzResourceGroup -Name $New_rg -Tag $tags $location

#Move_to_a_new_rg
$Sub = Get-AzSubscription | Where-Object {$_.Name -match "s-sis-eu-nonprod-01"}
$nic_id = $($virtual_Machine).NetworkProfile.NetworkInterfaces.id
Move-AzResource -DestinationResourceGroupName $(Get-AzResourceGroup -Name $New_rg).ResourceGroupName -DestinationSubscriptionId $sub.Id -ResourceId $Virtual_Machine.Id,$nic_id,
$Data_disk = $($Virtual_Machine.StorageProfile.DataDisks).Name
Foreach ($disk in $Data_disk)
{
    if ($disk -ne $null)
    {
    $data_disk_id = $(Get-AzResource -Name $disk).ResourceId
    Move-AzResource -DestinationResourceGroupName $(Get-AzResourceGroup -Name $New_rg).ResourceGroupName -DestinationSubscriptionId $sub.Id -ResourceId $data_disk_id -force
    }else
    {Write-Output "Disk name empty"}
}

