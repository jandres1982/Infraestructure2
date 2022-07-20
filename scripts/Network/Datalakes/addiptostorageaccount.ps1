## /*----------------------------------------------------------------
##   Add ip ranges to STORAGE Account please fill ipranges.txt, before running the script, thanks 
## ----------------------------------------------------------------*/

$myvault = "dlsprodssot04"
$rg = "rg-cis-nonprod-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $myvault  -IPRule (@{IPAddressOrRange=$iprange;Action="allow"})
}