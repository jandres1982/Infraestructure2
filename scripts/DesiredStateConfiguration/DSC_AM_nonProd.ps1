
#################################################################### Am non prod
Select-AzSubscription -Subscription "s-sis-am-nonprod-01"
$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_nonprod.txt

$VM_AM_NonProd = Get-Content "servers_list_am_nonprod.txt"
foreach ($vm in $VM_AM_NonProd)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}

