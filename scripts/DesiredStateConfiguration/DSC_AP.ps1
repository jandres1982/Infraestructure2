
#################################################################### Ap
Select-AzSubscription -Subscription "s-sis-ap-prod-01"
$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_ap.txt
$VM_AP = Get-Content "servers_list_ap.txt"
foreach ($vm in $VM_AP)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"

az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}
