# SQL vm deploy

$vm = $args[0]
$rg = $args[1]
$vm_size = $args[2]
$subnet = $args[3]
$sysdb_0 = $args[4]
$userdb_1 = $args[5]
$logdb_2 = $args[6]
$tempdb_3 = $args[7]

$Parameters_Base = "/ARM_Templates/ARM_VM/TEST/SQL/parameters.json"
$Template_2019 = "/ARM_Templates/ARM_VM/TEST/SQL/template.json"
$Template = "./template_2021.json"
New-Item -ItemType directory -Path ".\server_json" -ErrorAction SilentlyContinue
##########################################################################
$Parameters = Get-Content $Parameters_Base | out-string | ConvertFrom-Json
$json = Get-Content $Parameters_Base -raw | convertfrom-json
$json.parameters.networkInterfaceName.value = "$vm`_01"
$json.parameters.subnetName.value = $subnet
$json.parameters.virtualMachineName.value = $vm
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

$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath "/ARM_Templates/ARM_VM/TEST/SQL/server_json/$vm.json"

# New paremeters file with modifications in code
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateParameterFile "/ARM_Templates/ARM_VM/TEST/SQL/server_json/$vm.json" -TemplateFile $Template


$Parameters.parameters.virtualMachineName.value = "$vm"
$Parameters.parameters.networkInterfaceName.value = "$vm`_01"

$Parameters | ConvertTo-Json | Out-File -FilePath "/ARM_Templates/ARM_VM/TEST/SQL/Parameters.json" -Encoding utf8 -Force
#command to create a Vm
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $Template_2019 -TemplateParameterFile "/ARM_Templates/ARM_VM/TEST/SQL/parameters.json"
