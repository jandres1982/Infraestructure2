$myvault = "dlsqualssot04"
$rg = "rg-gis-qual-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $myvault  -IPRule (@{IPAddressOrRange=$iprange;Action="allow"})
}