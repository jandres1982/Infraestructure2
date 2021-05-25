   
Connect-AzAccount

$servers = Import-Csv -Path c:\temp\servers.csv




foreach ($server in $servers)
    {​​​​​​​


    $nic = $server.server
    $ip = $server.ip
    $network = $server.network
    $subnetid = $server.subnet
    $rg = $server.rg

    $Subnet = Get-AzVirtualNetwork -Name $network
    $IPconfig = New-AzNetworkInterfaceIpConfig -Name "IPConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress "$ip" -SubnetId $Subnet.Subnets[$subnetid].id
    New-AzNetworkInterface -Name $nic -ResourceGroupName $rg -Location "northeurope" -IpConfiguration $IPconfig
    }​​​​​​​







