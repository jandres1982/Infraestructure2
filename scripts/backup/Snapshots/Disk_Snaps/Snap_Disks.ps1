##Set Subscription##
set-azcontext -subscription $sub

##Set Variables##
$snapshotName = "Snapshot_$vm"
$resourceGroup = Get-AzResourceGroup | Where-Object {$_.Tags.infrastructureservice -eq "snapshots"}
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$vm"}

##OS Disk Snapshot
$snapshot =  New-AzSnapshotConfig -SourceUri $vmDetails.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroup.ResourceGroupName

##DATA Disk Snapshots
$Data_disk = $($vmDetails | select-object -Property *).StorageProfile.DataDisks.Name
$i = 0
Foreach ($disk in $Data_disk)
    {
    if ($disk -ne $null)
        {
        $data_disk_id = $(Get-AzResource -Name $disk).ResourceId
        $snapshot =  New-AzSnapshotConfig -SourceUri $data_disk_id -Location $location -CreateOption copy
        $Snap_name = $snapshotName+$i
        New-AzSnapshot -Snapshot $snapshot -SnapshotName $Snap_name -ResourceGroupName $resourceGroup.ResourceGroupName
        $i++
    }else
        {Write-Output "Disk name empty"}
    }
