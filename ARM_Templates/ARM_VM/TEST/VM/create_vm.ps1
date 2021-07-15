# VM deploy

# Devops Variables
$vm = $args[0]
$rg = $args[1]
$vm_size = $args[2]
$subnet = $args[3]
$sysdb_0 = $args[4]
$userdb_1 = $args[5]
$logdb_2 = $args[6]
$tempdb_3 = $args[7]
$subs = $args[8]
$datadisk = $args[9]
$sql = $arg[10]
$so = $arg[11]

# Variables
$parameters_base = ".\_Infraestructure\ARM_Templates\ARM_VM\TEST\VM\parameters_prod.json"
$template_base = ".\_Infraestructure\ARM_Templates\ARM_VM\TEST\VM\template_prod.json"

# Main
set-azcontext -subscripction $subs

New-Item -ItemType directory -Path ".\server_json" -ErrorAction SilentlyContinue
$tjson = Get-Content $template_base -raw | convertfrom-json
$json = Get-Content $parameters_base -raw | convertfrom-json

$json.parameters.virtualMachineName.value = $vm 
$json.parameters.virtualMachineComputerName.value = $vm
$json.parameters.networkInterfaceName.value = "$vm`_01"
$json.parameters.subnetName.value = $subnet
$json.parameters.virtualMachineRG.value = $rg
$json.parameters.virtualMachineSize.value = $vm_size
if ($sql -eq "yes")
{
    $json.parameters.dataDisks.value[0].name = "$vm`_sysdb_0"
    $json.parameters.dataDisks.value[0].caching = "ReadOnly"
    $json.parameters.dataDiskResources.value[0].name = "$vm`_sysdb_0"
    $json.parameters.dataDiskResources.value[0].sku = "Premium_LRS"
    $json.parameters.dataDiskResources.value[0].properties[0].diskSizeGB = "$sysdb_0"
    $json.parameters.dataDisks.value[1].name = "$vm`_userdb_1"
    $json.parameters.dataDisks.value[1].caching = "ReadOnly"
    $json.parameters.dataDiskResources.value[1].name = "$vm`_userdb_1"
    $json.parameters.dataDiskResources.value[1].sku = "Premium_LRS"
    $json.parameters.dataDiskResources.value[1].properties[0].diskSizeGB = "$userdb_1"
    $json.parameters.dataDisks.value[2].name = "$vm`_logdb_2"
    $json.parameters.dataDisks.value[2].caching = "None"
    $json.parameters.dataDiskResources.value[2].name = "$vm`_logdb_2"
    $json.parameters.dataDiskResources.value[2].sku = "Premium_LRS"
    $json.parameters.dataDiskResources.value[2].properties[0].diskSizeGB = "$logdb_2"
    $json.parameters.dataDisks.value[3].name = "$vm`_tempdb_3"
    $json.parameters.dataDisks.value[3].caching = "ReadOnly"
    $json.parameters.dataDiskResources.value[3].name = "$vm`_tempdb_3"
    $json.parameters.dataDiskResources.value[3].sku = "Premium_LRS"
    $json.parameters.dataDiskResources.value[3].properties[0].diskSizeGB = "$tempdb_3"   
}
else
{    
    $json.parameters.dataDisks.value[0].name = "$vm`_datadisk_0"
    $json.parameters.dataDisks.value[0].caching = "None"
    $json.parameters.dataDiskResources.value[0].name = "$vm`_datadisk_0"
    $json.parameters.dataDiskResources.value[0].sku = "StandardSSD_LRS"
    $json.parameters.dataDiskResources.value[0].properties[0].diskSizeGB = "$datadisk"
}
switch ($subs)
{
    "s-sis-eu-prod-01" 
    {
        $json.parameters.location.value = "northeurope"
        $json.parameters.virtualNetworkId.value = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/RG_NETWORK_PROD/providers/Microsoft.Network/virtualNetworks/EU-PROD-VNET"
        $json.parameters.diagnosticsStorageAccountName.value = "stproddiagnostic0002"
        $json.parameters.diagnosticsStorageAccountId.value = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-cis-prod-storage-01/providers/Microsoft.Storage/storageAccounts/stproddiagnostic0002"
        if ($so -eq "2019")
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2019datacenter-19052021-01/versions/0.0.1" 
        }
        else
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-cis-prod-server-01/providers/Microsoft.Compute/images/img-prodwin2016-1835-14102020-01"
        }
    }
    "s-sis-eu-nonprod-01" 
    {
        $json.parameters.location.value = "northeurope"
        $json.parameters.virtualNetworkId.value = "/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/rg-cis-nonprod-network-01/providers/Microsoft.Network/virtualNetworks/EU-NONPROD-VNET"
        $json.parameters.diagnosticsStorageAccountName.value = "stnonproddiagnostic0001"
        $json.parameters.diagnosticsStorageAccountId.value = "/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/rg-cis-nonprod-storage-01/providers/Microsoft.Storage/storageAccounts/stnonproddiagnostic0001"
        if ($so -eq "2019")
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2019datacenter-19052021-01/versions/0.0.1"
        }
        else
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-cis-prod-server-01/providers/Microsoft.Compute/images/img-prodwin2016-1835-14102020-01"
        }
    }
    "s-sis-ap-prod-01" 
    {
        $json.parameters.location.value = "southeastasia"
        $json.parameters.virtualNetworkId.value = "/subscriptions/59c20947-4965-45c4-99f3-12be96106119/resourceGroups/rg-cis-prod-network-02/providers/Microsoft.Network/virtualNetworks/vnet-prod-asse-01"
        $json.parameters.diagnosticsStorageAccountName.value = "stproddiagnostic0003"
        $json.parameters.diagnosticsStorageAccountId.value = "/subscriptions/59c20947-4965-45c4-99f3-12be96106119/resourceGroups/rg-cis-prod-storage-02/providers/Microsoft.Storage/storageAccounts/stproddiagnostic0003"
        $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/59c20947-4965-45c4-99f3-12be96106119/resourceGroups/rg-cis-prod-server-02/providers/Microsoft.Compute/images/img-prodwin2019-1835-14102020-01"
        
    }
    "s-sis-am-prod-01" 
    {
        $json.parameters.location.value = "eastus2"
        $json.parameters.virtualNetworkId.value = "/subscriptions/e03c610e-a71c-4518-a4a3-8ce128fca34d/resourceGroups/rg-cis-prod-network-01/providers/Microsoft.Network/virtualNetworks/vnet-prod-use2-01"
        $json.parameters.diagnosticsStorageAccountName.value = "stproddiagnostic0004"
        $json.parameters.diagnosticsStorageAccountId.value = "/subscriptions/e03c610e-a71c-4518-a4a3-8ce128fca34d/resourceGroups/rg-cis-prod-storage-01/providers/Microsoft.Storage/storageAccounts/stproddiagnostic0004"
        $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2019datacenter-19052021-01"
    }
    "s-sis-am-nonprod-01" 
    {
        $json.parameters.location.value = "eastus2"
        $json.parameters.virtualNetworkId.value = "/subscriptions/8528129a-0394-4057-ac4e-0fec3da2246d/resourceGroups/rg-cis-nonprod-network-01/providers/Microsoft.Network/virtualNetworks/vnet-nonprod-use2-01"
        $json.parameters.diagnosticsStorageAccountName.value = "stproddiagnostic0002"
        $json.parameters.diagnosticsStorageAccountId.value = "/subscriptions/8528129a-0394-4057-ac4e-0fec3da2246d/resourceGroups/rg-cis-nonprod-storage-01/providers/Microsoft.Storage/storageAccounts/stnonproddiagnostic0002"
        if ($so -eq "2019")
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/505ead1a-5a5f-4363-9b72-83eb2234a43d/resourceGroups/rg-gis-prod-imagegallery-01/providers/Microsoft.Compute/galleries/ig_gis_win_prod/images/img-prod-2019datacenter-19052021-01"
        }
        else
        {
            $tjson.resources.virtualMachineName.value.properties.imageReference.id = "/subscriptions/7fa3c3a2-7d0d-4987-a30c-30623e38756c/resourceGroups/rg-cis-qual-server-01/providers/Microsoft.Compute/images/img-prodwin2016-1835-14102020-01"
        }
    }
}
$tjson | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\server_json\$vm`_t.json"
$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\server_json\$vm`_p.json"

# Create Vm
New-AzResourceGroupDeployment -ResourceGroupName $rg  -TemplateFile ".\server_json\$vm`_t.json" -TemplateParameterFile ".\server_json\$vm`_p.json"
