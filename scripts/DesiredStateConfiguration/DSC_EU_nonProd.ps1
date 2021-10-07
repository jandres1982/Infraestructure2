
#################################################################### EU non prod
Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonprod.txt

$VM_EU_NonProd = Get-Content "servers_list_eu_nonprod.txt"
foreach ($vm in $VM_EU_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"
az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}
