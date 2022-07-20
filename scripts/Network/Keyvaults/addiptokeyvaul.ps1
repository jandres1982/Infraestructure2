## /*----------------------------------------------------------------
##    Add IP ranges to Key vaults. Please, full fill ipranges.txt
## --------------------------------------------------------------*/

$myvault = "kv-prod-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzKeyVaultNetworkRule -VaultName $myvault -IpAddressRange $iprange -PassThru
}
