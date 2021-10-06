



##################################################################
#Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
#$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonProd.txt
#Select-AzSubscription -Subscription "s-sis-eu-prod-01"
#$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_Prod.txt
#Select-AzSubscription -Subscription "s-sis-ap-prod-01"
#$VM_AP = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_Prod.txt
#Select-AzSubscription -Subscription "s-sis-am-prod-01"
#$VM_AM_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_ap.txt
#Select-AzSubscription -Subscription "s-sis-am-nonprod-01"
#$VM_AM_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_nonProd.txt


####################################################################

Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonProd.txt

$VM_EU_NonProd = servers_list_eu_nonProd.txt

foreach ($vm in $VM_EU_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"
az vm run-command invoke  --command-id RunPowerShellScript --name $vm -g $rg --scripts "hostname"
}