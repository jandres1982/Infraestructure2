# SQL vm deploy

# Devops Variables
$vm = $args[0]
$rg = $args[1]
$vm_size = $args[2]
$subnet = $args[3]
$sysdb_0 = $args[4]
$userdb_1 = $args[5]
$logdb_2 = $args[6]
$tempdb_3 = $args[7]

# Variables
$parameters_base = ".\_Infraestructure\ARM_Templates\ARM_VM\TEST\SQL\parameters.json"
$template = ".\_Infraestructure\ARM_Templates\ARM_VM\TEST\SQL\template.json"

# Main
New-Item -ItemType directory -Path ".\server_json" -ErrorAction SilentlyContinue
$json = Get-Content $parameters_base -raw | convertfrom-json
$json.parameters.virtualMachineName.value = $vm 
$json.parameters.networkInterfaceName.value = "$vm`_01"
$json.parameters.subnetName.value = $subnet
$json.parameters.virtualMachineComputerName.value = $vm
$json.parameters.virtualMachineRG.value = $rg
$json.parameters.dataDisks.value[0].name = "$vm`_sysdb_0"
$json.parameters.dataDiskResources.value[0].name = "$vm`_sysdb_0"
$json.parameters.dataDiskResources.value[0].properties[0].diskSizeGB = "$sysdb_0"
$json.parameters.dataDisks.value[1].name = "$vm`_userdb_1"
$json.parameters.dataDiskResources.value[1].name = "$vm`_userdb_1"
$json.parameters.dataDiskResources.value[1].properties[0].diskSizeGB = "$userdb_1"
$json.parameters.dataDisks.value[2].name = "$vm`_logdb_2"
$json.parameters.dataDiskResources.value[2].name = "$vm`_logdb_2"
$json.parameters.dataDiskResources.value[2].properties[0].diskSizeGB = "$logdb_2"
$json.parameters.dataDisks.value[3].name = "$vm`_tempdb_3"
$json.parameters.dataDiskResources.value[3].name = "$vm`_tempdb_3"
$json.parameters.dataDiskResources.value[3].properties[0].diskSizeGB = "$tempdb_3"
$json.parameters.virtualMachineSize.value = $vm_size
$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\server_json\$vm.json"

# Create Vm
New-AzResourceGroupDeployment -ResourceGroupName $rg  -TemplateFile $template -TemplateParameterFile ".\server_json\$vm.json"
