##Variables
$sub = "s-sis-eu-nonprod-01"
$vm = "zzzwsr0010"
$RSV = "rsv-nonprod-euno-lrsbackup-02"
$RSV_RG = "rg-cis-nonprod-backup-01"
$location = "northeurope"
$Virtual_Machine =  get-azvm -name $vm

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

$vm_rg = $Virtual_Machine.ResourceGroupName
$Old_rg = get-azresourceGroup -name $VM_RG
$tags = $Old_rg.tags
$Number = $VM_RG.Substring($($VM_RG.Length-2))
$add = [int]$Number += 1
$New_number = "0"+[string]$add
$New_rg = $($old_rg.ResourceGroupName.Remove($old_rg.ResourceGroupName.Length-2))+$New_number
New-AzResourceGroup -Name $New_rg -Tag $tags $location

#Move_to_a_new_rg

#Get-AzResource -ResourceGroupName $Virtual_Machine.ResourceGroupName | Format-table -wrap -Property ResourceId

$Sub = Get-AzSubscription | Where-Object {$_.Name -match "s-sis-eu-nonprod-01"}

$Virtual_Machine = Get-AzResource -ResourceName $vm
#moving the VM
Move-AzResource -ResourceId $Virtual_Machine.ResourceId -DestinationResourceGroupName $New_rg -force
#moving OS disk
$Os_disk_id = $(Get-Azvm -Name $Virtual_Machine.name | select-object -Property *).StorageProfile.OsDisk.ManagedDisk.id
Move-AzResource -ResourceId $Os_disk_id -DestinationResourceGroupName $New_rg -force
#moving nic
$nic_id = $(Get-Azvm -Name $Virtual_Machine.name | select-object -Property *).NetworkProfile.NetworkInterfaces.id
Move-AzResource -ResourceId $nic_id -DestinationResourceGroupName $New_rg -force
#moving Data Disk
$Data_disk = $(Get-Azvm -Name $Virtual_Machine.name | select-object -Property *).StorageProfile.DataDisks.Name
$i = 0
Foreach ($disk in $Data_disk)
    {
    if ($disk -ne $null)
        {
        $data_disk_id = $(Get-AzResource -Name $disk).ResourceId
        Move-AzResource -ResourceId $data_disk_id -DestinationResourceGroupName $New_rg -force   
        #Write-Output $data_disk_id
        #New-Variable "DataDisk$i" "$data_disk_id"
        #$i++
        #Write-host $i
    }else
        {Write-Output "Disk name empty"}
    }

#Get-AzResource -ResourceGroupName "RG-CIS-TEST-SERVER-01" | Format-table -wrap -Property ResourceId

#$Resource = Get-AzResource -ResourceType "Microsoft.ClassicCompute/virtualmachine" -ResourceName $Virtual_Machine
#Move-AzResource -ResourceId $Resource.ResourceId -DestinationResourceGroupName "ResourceGroup14"
