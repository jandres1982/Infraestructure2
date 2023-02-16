## /*----------------------------------------------------------------
##    Add IP ranges to Key vaults. Please, full fill ipranges.txt
## --------------------------------------------------------------*/

#$subsriptionId = “subscription guid”
#Select-AzSubscription -Subscription $subsriptionId
#$ipranges = ((Get-AzNetworkServiceTag -Location eastus).Values | Where-Object { $_.Name -iin ("PowerPlatformInfra.NorthEurope" ,"PowerPlatformInfra.WestEurope")}).properties.AddressPrefixes

$myvault = "kv-prod-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzKeyVaultNetworkRule -VaultName $myvault -IpAddressRange $iprange -PassThru
}
