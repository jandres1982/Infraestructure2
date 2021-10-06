



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

#Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonProd.txt

$VM_EU_NonProd = Get-Content "servers_list_eu_nonProd.txt"

foreach ($vm in $VM_EU_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

$app_id = "70eacc9c-bde8-4b40-9e16-02620fc4e65b"
$tenant_id = "aa06dce7-99d7-403b-8a08-0c5f50471e64"
$se_id = "e48bf748-b756-4b9a-ab72-1a2ee2bceb98"
az login --service-principal --username $app_id --password $se_id --tenant $tenant_id
az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}