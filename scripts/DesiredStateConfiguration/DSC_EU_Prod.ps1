#################################################################### Ap
Select-AzSubscription -Subscription "s-sis-eu-prod-01"

$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_prod.txt

######################### Check MicrosoftMonitoringAgent extension is enable in the VM 

$extension = $(Get-AzVM -ResourceGroupName "RG-POR-PROD-FILESERVER-01" -Name "porwsr0014" -DisplayHint expand).extensions.name | Where-Object {$_ -eq "MicrosoftMonitoringAgent"}
if ($extension -eq "MicrosoftMonitoringAgent")
{
write-output "MicrosoftMonitoringAgent extension found in the server"
}else
{
    write-output "MicrosoftMonitoringAgent Agent not found"
}






################################################################################################


$VM_EU_Prod  = Get-Content "servers_list_eu_prod.txt"
foreach ($vm in $VM_EU_Prod)
{
$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"
az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"
}