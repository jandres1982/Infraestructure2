$rg = "RG_NETWORK_PROD"
$vnet_name = "EU-PROD-VNET"

$vnet = Get-AzVirtualNetwork -Name $vnet_name -ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig -Name "sub-dmz2domain-01" -VirtualNetwork $vnet

$nic = Get-AzNetworkInterface -Name "shhxap0298_02" -ResourceGroupName "rg-shh-prod-beyondtrustremotesupport-01"

$nic | Set-AzNetworkInterfaceIpConfig -Name ipconfig1 -PrivateIpAddress 10.38.31.73 -Subnet $subnet -Primary

$nic | Set-AzNetworkInterface



#$(get-azvm -Name shhxap0298).NetworkProfile.NetworkInterfaces[0] | Select-Object -Property *

$vm.NetworkProfile.NetworkInterfaces[0].Primary = $false
$vm.NetworkProfile.NetworkInterfaces[1].Primary = $true

$vm = get-azvm -Name shhxap0298
$(get-azvm -Name shhxap0298).NetworkProfile.NetworkInterfaces[0].Primary = $false
$(get-azvm -Name shhxap0298).NetworkProfile.NetworkInterfaces[1].Primary = $true
Update-AzVM -VM $vm -ResourceGroupName "rg-shh-prod-beyondtrustremotesupport-01"