#define the subnet ID, rg of the network, virtual network and subnet name --->
$subnet_id = az network vnet subnet show -g $(rgnet) --vnet-name $(vnet) --name $(subnet_mid) --query id

#Define an array of the servers and the ip that will have each one
$psarray = @(
 ('shhwsr2258' ,'10.37.9.62' ),
 ('shhwsr2259' ,'10.37.9.63' ),
 ('shhwsr2260' ,'10.37.9.64' ),
 ('shhwsr2261' ,'10.37.9.65')
)
#start counter to zero
$i="0"

#each item is the first row of the array

foreach($item in $psarray)
{

$nic = $item[$i]+"_01"
$ip = $item[$i+1]

az network nic ip-config update --resource-group $(rg) --nic-name $nic --subnet $subnet_id --name $(config) --private-ip-address $ip
  
}


#---------------------------------------------------------------------------------------------------------------------------------------------------
#$vm = gc $(System.DefaultWorkingDirectory)/_Infraestructure/scripts/Subnet_Change/Schindler_Draw/vm.txt
#$ip = gc $(System.DefaultWorkingDirectory)/_Infraestructure/scripts/Subnet_Change/Schindler_Draw/ip.txt
#This only work for 1 server and 1 ip
#foreach ($server in $vm)
#{
# foreach ($ip_add in $ip)
#{
# $subnet_id = az network vnet subnet show -g $(rgnet) --vnet-name $(vnet) --name $(subnet_mid) --query id
#az network nic ip-config update --resource-group $(rg) --nic-name "$server`_01" --subnet $subnet_id --name $(config) --private-ip-address $ip_add   
#}
#}