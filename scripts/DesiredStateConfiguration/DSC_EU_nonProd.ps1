

#################################################################### EU non prod


Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonprod.txt
$VM_EU_NonProd = Get-Content "servers_list_eu_nonprod.txt"




[int]$num_T = $VM_EU_NonProd.Count #Per_variables
[int]$num_R = $num_T #Per_variables
[int]$Per = $null #Per_variables
[int]$Per_1 = $null #Per_variables

foreach ($vm in $VM_EU_NonProd)
{


##########################  Check $per


write-host "Remaining Servers $num_R"
$num_R = $num_R - 1
$Per = 100 - (($num_R * 100) / $num_T)

if ($per -eq $per_1)
{
#write-host "is equal"
}else
{
Write-host "Servers checked $per%"
}
$per_1 = $per


##########################  Check $per

$rg = (get-azvm -Name $vm).ResourceGroupName
write-host "$vm and $rg"
az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"



}
