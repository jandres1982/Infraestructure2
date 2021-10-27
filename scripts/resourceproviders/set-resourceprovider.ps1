$subscriptions = $(Get-AzSubscription).Name

foreach ($subscription in $subscriptions) 
{
set-azcontext -subscription $subscription 
write-host $subscription
Register-AzResourceProvider -ProviderNamespace Microsoft.ManagedServices
}