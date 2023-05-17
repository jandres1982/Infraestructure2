$myvault = "dlsqualssot04"
$rg = "rg-gis-qual-ssot-01"
$ipranges = get-comnmand "ipranges.txt"
foreach ($iprange in $ipranges) {
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $myvault  -IPRule (@{IPAddressOrRange = $iprange; Action = "allow" })
}

$stacc = "dlsqualssot04"
$rg = "rg-gis-qual-ssot-01"
$ips = az storage account network-rule list -g $rg --account-name $stacc
$values = $ips | ConvertFrom-Json
$IpList = $values.ipRules.ipAddressOrRange




#az account set --subscription s-sis-eu-nonprod-01
#az cloud list --output table
#az cloud set --name AzureCloud