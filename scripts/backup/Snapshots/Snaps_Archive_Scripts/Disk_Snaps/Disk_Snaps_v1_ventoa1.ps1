$resourceGroup = "RG-MIL-QUAL-DYNAMICS-01"
$location= "North Europe"
$vmName = "milwsr4153"
$snapshotName = "Snapshot_$vmName"

#$date = get-date
#Get-Date -Format "dddd MM/dd/yyyy HH:mm K"

$vmDetails = Get-AzVM -Name $vmName -ResourceGroupName $resourceGroup

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