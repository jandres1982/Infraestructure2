
param([string]$vm)

#$subs = @("s-sis-eu-nonprod-01","s-sis-ap-prod-01","s-sis-eu-prod-01","s-sis-am-prod-01","s-sis-am-nonprod-01")

#param([string]$vm)
#$vm = "shhwsr2242"
$subs = @("s-sis-am-prod-01","s-sis-am-nonprod-01")

foreach ($sub in $subs)
{
    Select-AzSubscription -Subscription $sub
    az account set --subscription $sub
    #$vm = get-azvm -Name $vm
        if (get-azvm -Name $vm)
            {
                Write-Host "Working in $vm"
                $vm = get-azvm -Name $vm
                $rg = $vm.ResourceGroupName
                az vm stop --resource-group $rg --name $vm
                az vm deallocate -g $rg -n $vm
                $osdisk = $vm.StorageProfile.OSDisk.Name
                az disk update -g $rg -n $osdisk --sku StandardSSD_LRS
                $datadisk = $vm.StorageProfile.DataDisks.Name
                    foreach ($disk in $datadisk)
                        {
                        az disk update -g $rg -n $disk --sku StandardSSD_LRS
                        }
                         az vm start -g $rg -n $vm
           
            }else
                 {
                 Write-host "$vm is not found in $sub"

                 }
}