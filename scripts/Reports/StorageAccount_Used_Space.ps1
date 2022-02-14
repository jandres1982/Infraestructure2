$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-*"} 
foreach ($sub in $subs)
{
set-azcontext -Subscription $sub.Name
$storages=Get-AzStorageAccount
foreach ($storage in $storages)
{
$capacity=Get-AzMetric -ResourceId $storage.id -MetricName "UsedCapacity" -AggregationType Average
$storage.StorageAccountName | Export-Csv -Path .\storage_used_space.csv
$capacity.data | Export-Csv -Path .\storage_used_space.csv
}
}