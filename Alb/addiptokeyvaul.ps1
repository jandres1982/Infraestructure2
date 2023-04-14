$myvault = "kv-prod-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzKeyVaultNetworkRule -VaultName $myvault -IpAddressRange $iprange -PassThru
}