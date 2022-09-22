set-azcontext -subscription $(sub)

$snapshotName = "Snapshot_$(vm)"


$resourceGroup = get-azresourcegroup | Where-Object {$_.ResourceGroupName -match "rg-cis-*-snapshot*"}
$vmDetails = Get-AzVM | Where-Object {$_.Name -eq "$(vm)"}

#OS DISK SNAPSHOT
$snapshot =  New-AzSnapshotConfig -SourceUri $vmDetails.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
New-AzSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroup

#DATA DISK SNAPSHOT
$Data_disk = $($vmDetails | select-object -Property *).StorageProfile.DataDisks.Name
$i = 0
Foreach ($disk in $Data_disk)
    {
    if ($disk -ne $null)
        {
        $data_disk_id = $(Get-AzResource -Name $disk).ResourceId
        $snapshot =  New-AzSnapshotConfig -SourceUri $data_disk_id -Location $location -CreateOption copy
        $Snap_name = $snapshotName+$i
        New-AzSnapshot -Snapshot $snapshot -SnapshotName $Snap_name -ResourceGroupName $resourceGroup
        $i++
    }else
        {Write-Output "Disk name empty"}
    }