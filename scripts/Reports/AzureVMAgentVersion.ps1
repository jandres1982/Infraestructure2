$date = $(get-date -format yyyy-MM-ddTHH-mm)
$subs = @("s-sis-eu-nonprod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01","s-sis-ap-prod-01","s-sis-ch-prod-01","s-sis-ch-nonprod-01")
foreach ($sub in $subs)
{

Select-AzSubscription -Subscription $sub
#$Sub = Get-AzSubscription -Subscription $sub
$vms = Get-AzVM  | Where-Object {$_.Name -clike "*wsr*"}

    foreach ($vm in $vms) {
        #$agent = $vm | Select -ExpandProperty OSProfile | Select -ExpandProperty Windowsconfiguration | Select ProvisionVMAgent
        #Write-Host $vm.Name $agent.ProvisionVMAgent
        $status = get-azvm -Name $vm.name -ResourceGroupName $vm.ResourceGroupName -Status
        [string]$VmName = $status.Name
        [string]$Version = $status.VMAgent.VmAgentVersion
        
        Write-Output "$sub,$VmName,$Version" >> "c:\temp\AzureVMAgentVersion_$date.txt"
    }

}