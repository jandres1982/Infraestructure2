#################################################################### EU prod
Select-AzSubscription -Subscription "s-sis-eu-prod-01"

workflow DSC
{

$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'}
#$VM_EU_Prod = Get-Content "servers_list_eu_prod.txt"


foreach -parallel ($vm in $VM_EU_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-output "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "hostname"
}
}

DSC