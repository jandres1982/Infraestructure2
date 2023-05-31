$stacc_source = "dlsdevcs01"
$rg_source = "rg-gis-dev-ssot-01"
$sub = "s-sis-eu-nonprod-01"
Set-AzContext -Subscription $sub
$ips = az storage account network-rule list -g $rg_source --account-name $stacc_source
$values = $ips | ConvertFrom-Json
$IpList = $values.ipRules.ipAddressOrRange




#az account set --subscription s-sis-eu-nonprod-01
#az cloud list --output table
#az cloud set --name AzureCloud

#$ipranges = gc "ipranges.txt"

$stacc = "dlsprodcs01"
$rg = "rg-gis-prod-ssot"
$sub = "s-sis-eu-prod-01"

Set-AzContext -Subscription $sub
foreach ($iprange in $IpList) {
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rg -Name $stacc  -IPRule (@{IPAddressOrRange = $iprange; Action = "allow" })
    #(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName "$rg" -Name "$stacc").ResourceAccessRules | Remove-AzStorageAccountNetworkRule -ResourceGroupName "$rg" -Name "$stacc"
    #(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName "$rg" -Name "$stacc").IpRules | Remove-AzStorageAccountNetworkRule -ResourceGroupName "$rg" -Name "$stacc"
}

$stacc_source = "dlsdevcs01"
$rg_source = "rg-gis-dev-ssot-01"
$ips = az storage account network-rule list -g $rg_source --account-name $stacc_source
$values = $ips | ConvertFrom-Json
$IpList = $values.ipRules.ipAddressOrRange