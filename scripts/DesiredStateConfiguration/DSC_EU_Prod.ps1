#################################################################### Ap
Select-AzSubscription -Subscription "s-sis-eu-prod-01"

$(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_prod.txt

$VM_EU_Prod  = Get-Content "servers_list_eu_prod.txt"
$VM_EU_Prod  = $VM_EU_Prod | Sort-Object


[int]$num_T = $VM_EU_Prod.Count #Per_variables
[int]$num_R = $num_T #Per_variables
[int]$Per = $null #Per_variables
[int]$Per_1 = $null #Per_variables



foreach ($vm in $VM_EU_Prod)
{

$rg = (get-azvm -Name $vm).ResourceGroupName



##################### Checking VM's Status #################################


If ($(get-azvm -Name $vm -ResourceGroupName $rg -Status).Statuses.displaystatus | where-object {$_ -eq "VM running"})
{

#Write-output "VM is Running"


######################### Check MicrosoftMonitoringAgent extension is enable in the VM 
$extension = $(Get-AzVM -ResourceGroupName "$rg" -Name "$vm" -DisplayHint expand).extensions.name | Where-Object {$_ -eq "MicrosoftMonitoringAgent"}
if ($extension -eq "MicrosoftMonitoringAgent")
{
        $status = "MicrosoftMonitoringAgent"
}       else
       {
       $extension2 = $(Get-AzVM -ResourceGroupName "$rg" -Name "$vm" -DisplayHint expand).extensions.name | Where-Object {$_ -eq "Microsoft.Insights.LogAnalyticsAgent"}
       if ($extension2 -eq "Microsoft.Insights.LogAnalyticsAgent")
        {
        $status = "Microsoft.Insights.LogAnalyticsAgent"
        }else #no MMA agent Found
             {       
              $status = "MicrosoftMonitoringAgent Installation" 
              #write-output "MMA Agent not found, pushing installation"
              
              
              $PublicSettings = @{"workspaceId" = "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"}
              $ProtectedSettings = @{"workspaceKey" = "1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA=="}
              
              Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
              -ResourceGroupName "$rg" `
              -VMName "$vm" `
              -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
              -ExtensionType "MicrosoftMonitoringAgent" `
              -TypeHandlerVersion 1.0 `
              -Settings $PublicSettings `
              -ProtectedSettings $ProtectedSettings `
              -Location NorthEurope
              }

        }


#az account set --subscription <subscription-id>
################################################################################################



#az vm run-command invoke --command-id RunPowerShellScript --name "$vm" -g $rg --scripts "@DSC_MMA.ps1"


}else
{$Status = "OFF"
}


##########################  Check $per START ###############################


#write-host "Remaining Servers $num_R"
$num_R = $num_R - 1
$Per = 100 - (($num_R * 100) / $num_T)


if ($per -eq $per_1)
{
#write-host "is equal"
Write-host "$num_R | $vm | $rg | $Status"
}else
{
Write-host "$num_R | $vm | $rg | $Status | $per%"
#Show Percentage
}
$per_1 = $per


##########################  Check $per END #################################


}



#PS /home/antonio> az vm extension list -g "rg-cis-test-server-01" --vm-name "zzzwsr0010"
#[
#  {
#    "autoUpgradeMinorVersion": true,
#    "enableAutomaticUpgrade": null,
#    "forceUpdateTag": null,
#    "id": "/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/rg-cis-test-server-01/providers/Microsoft.Compute/virtualMachines/zzzwsr0010/extensions/Microsoft.Insights.LogAnalyticsAgent",
#    "instanceView": null,
#    "location": "northeurope",
#    "name": "Microsoft.Insights.LogAnalyticsAgent",
#    "protectedSettings": null,
#    "provisioningState": "Succeeded",
#    "publisher": "Microsoft.EnterpriseCloud.Monitoring",
#    "resourceGroup": "rg-cis-test-server-01",
#    "settings": {
#      "workspaceId": "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"
#    },
#    "suppressFailures": null,
#    "tags": {
#      "applicationowner": "alfonso.marques@schindler.com",
#      "costcenter": "120011300",
#      "infrastructureservice": "si-server-hardware-operating-system",
#      "kg": "sis",
#      "serviceowner": "teodora.iliuta@schindler.com",
#      "technicalcontact": "alfonso.marques@schindler.com"
#    },
#    "type": "Microsoft.Compute/virtualMachines/extensions",
#    "typeHandlerVersion": "1.0",
#    "typePropertiesType": "MicrosoftMonitoringAgent"
#  }
#]



#PS /home/antonio> az vm extension list -g "rg-par-prod-outputmgmt-01" --vm-name "parwsr0108"
#[
#  {
#    "autoUpgradeMinorVersion": true,
#    "enableAutomaticUpgrade": null,
#    "forceUpdateTag": null,
#    "id": "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-par-prod-outputmgmt-01/providers/Microsoft.Compute/virtualMachines/parwsr0108/extensions/MicrosoftMonitoringAgent",
#    "instanceView": null,
#    "location": "northeurope",
#    "name": "MicrosoftMonitoringAgent",
#    "protectedSettings": null,
#    "provisioningState": "Succeeded",
#    "publisher": "Microsoft.EnterpriseCloud.Monitoring",
#    "resourceGroup": "rg-par-prod-outputmgmt-01",
#    "settings": {
#      "workspaceId": "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"
#    },
#    "suppressFailures": null,
#    "tags": {
#      "applicationowner": "brigitte.kingue.priso@schindler.com",
#      "costcenter": "120036060",
#      "infrastructureservice": "outputmgmt",
#      "kg": "par",
#      "serviceowner": "brigitte.kingue.priso@schindler.com",
#      "technicalcontact": "serge.rollin@schindler.com"
#    },
#    "type": "Microsoft.Compute/virtualMachines/extensions",
#    "typeHandlerVersion": "1.0",
#    "typePropertiesType": "MicrosoftMonitoringAgent"
#  },
#  {
#    "autoUpgradeMinorVersion": true,
#    "enableAutomaticUpgrade": null,
#    "forceUpdateTag": null,
#    "id": "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-par-prod-outputmgmt-01/providers/Microsoft.Compute/virtualMachines/parwsr0108/extensions/SqlIaasExtension",
#    "instanceView": null,
#    "location": "northeurope",
#    "name": "SqlIaasExtension",
#    "protectedSettings": null,
#    "provisioningState": "Failed",
#    "publisher": "Microsoft.SqlServer.Management",
#    "resourceGroup": "rg-par-prod-outputmgmt-01",
#    "settings": {
#      "DeploymentTokenSettings": {
#        "DeploymentToken": 1752625104
#      },
#      "SqlManagement": {
#        "IsEnabled": false
#      }
#    },
#    "suppressFailures": null,
#    "tags": {
#      "applicationowner": "brigitte.kingue.priso@schindler.com",
#      "costcenter": "120036060",
#      "infrastructureservice": "outputmgmt",
#      "kg": "par",
#      "serviceowner": "brigitte.kingue.priso@schindler.com",
#      "technicalcontact": "serge.rollin@schindler.com"
#    },
#    "type": "Microsoft.Compute/virtualMachines/extensions",
#    "typeHandlerVersion": "2.0",
#    "typePropertiesType": "SqlIaaSAgent"
#  }
#]