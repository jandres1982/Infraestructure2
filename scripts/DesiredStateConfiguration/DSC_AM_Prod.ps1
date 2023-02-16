
#################################################################### Am Prod
Select-AzSubscription -Subscription "s-sis-am-prod-01"
$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_prod.txt
$VM_AM_Prod = Get-Content "servers_list_am_prod.txt"
foreach ($vm in $VM_AM_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}
