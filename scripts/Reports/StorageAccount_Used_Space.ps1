$storges=Get-AzStorageAccount
foreach ($storage in $storages)
{
$capacity=Get-AzMetric -ResourceId $storage.id -MetricFilter "UsedCapacity" -AggregationType Average
$capacity.data
}