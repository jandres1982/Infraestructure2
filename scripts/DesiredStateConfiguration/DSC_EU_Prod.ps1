#################################################################### EU prod
Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_prod.txt

$VM_EU_Prod = Get-Content "servers_list_eu_prod.txt"
foreach ($vm in $VM_EU_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}