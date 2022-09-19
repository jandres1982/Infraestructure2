Set-AzContext -Subscription s-sis-am-prod-01

$nics = (Get-AzNetworkInterface | Where-Object {$_.IpConfigurations.PrivateIpAllocationMethod -eq 'dynamic'} | Where-Object {$_.VirtualMachine.id -like '*wsr*'}).Name > "D:\Repository\Working\Antonio\Set_Ip_Static\nics_dynamic_am_prod.txt"
$nics = Get-Content "D:\Repository\Working\Antonio\Set_Ip_Static\nics_dynamic_am_prod.txt"
foreach ($nic in $nics)
{
Write-Host $nic
$nic_full = Get-AzNetworkInterface -name $nic
$ip = $(Get-AzNetworkInterface -Name $nic).IpConfigurations.PrivateIpAddress
$config_name = $(Get-AzNetworkInterface -Name $nic).IpConfigurations.name
$subnet = $(Get-AzNetworkInterface -Name $nic).IpConfigurations.subnet.id
$nic_full | Set-AzNetworkInterfaceIpConfig -Name $config_name -PrivateIpAddress $ip -SubnetId $subnet
$nic_full | Set-AzNetworkInterface

}


