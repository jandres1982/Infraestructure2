## /*----------------------------------------------------------------
##   Add ip ranges to STORAGE Account please fill ipranges.txt, before running the script, thanks 
## ----------------------------------------------------------------*/

#$subsriptionId = “subscription guid”
#Select-AzSubscription -Subscription $subsriptionId
#$ipranges = ((Get-AzNetworkServiceTag -Location eastus).Values | Where-Object { $_.Name -iin ("PowerPlatformInfra.NorthEurope" ,"PowerPlatformInfra.WestEurope")}).properties.AddressPrefixes

$myvault = "dlsprodssot04"
$rg = "rg-cis-nonprod-ssot-01"
$ipranges = gc "ipranges.txt"
foreach ($iprange in $ipranges)
{
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $myvault  -IPRule (@{IPAddressOrRange=$iprange;Action="allow"})
}