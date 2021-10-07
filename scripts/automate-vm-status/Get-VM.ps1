


#################################################################### EU prod
Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_prod.txt

$VM_EU_Prod = Get-Content "servers_list_eu_prod.txt"
foreach ($vm in $VM_EU_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}
#################################################################### EU non prod
Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonprod.txt

$VM_EU_NonProd = Get-Content "servers_list_eu_nonprod.txt"
foreach ($vm in $VM_EU_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}

#################################################################### Ap
Select-AzSubscription -Subscription "s-sis-ap-prod-01"
$VM_AP = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_ap.txt
$VM_AP = Get-Content "servers_list_ap.txt"
foreach ($vm in $VM_AP)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}

#################################################################### Am Prod
Select-AzSubscription -Subscription "s-sis-am-prod-01"
$VM_AM_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_prod.txt
$VM_AM_Prod = Get-Content "servers_list_am_prod.txt"
foreach ($vm in $VM_AM_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}

#################################################################### Am non prod
Select-AzSubscription -Subscription "s-sis-am-nonprod-01"
$VM_AM_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_nonprod.txt

$VM_AM_NonProd = Get-Content "servers_list_am_nonprod.txt"
foreach ($vm in $VM_AM_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}

#################################################################### 