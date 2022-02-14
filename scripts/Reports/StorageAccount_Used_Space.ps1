$subs=Get-AzSubscription | Where-Object {$_.Name -match "s-sis-*"}
foreach ($sub in $subs)
{
set-azcontext -Subscription $sub.Name
$storages=Get-AzStorageAccount
foreach ($storage in $storages)
{
$capacity=Get-AzMetric -ResourceId $storage.id -MetricName "UsedCapacity" -AggregationType Average -WarningAction SilentlyContinue
$St_name = $storage.StorageAccountName
[int64]$value = $capacity.Data.average / 1024
$value = $value /1024
$Subscription = $sub.name
Write-output "$Subscription,$St_name,$value" >> Storage_account_Size.txtls
}
}