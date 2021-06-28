# SQL vm deploy

$vm = $args[0]
$rg = $args[1]
$vm_size = $args[2]
$subnet = $args[3]
$disk_size = $args[4]


$Parameters_Base = ".\sql\parameters.json"
$Template_2019 = ".\sql\template.json"

=======
$Template = ".\template_2019.json"
#Write-Output $vm
#Write-host $Parameters_Base
New-Item -ItemType directory -Path ".\server_json" -ErrorAction SilentlyContinue
##########################################################################
$Parameters = Get-Content $Parameters_Base | out-string | ConvertFrom-Json
=======
$json = Get-Content $Parameters_Base -raw | convertfrom-json
$json.parameters.networkInterfaceName.value = "$vm`_01"
$json.parameters.subnetName.value = $subnet
$json.parameters.virtualMachineName.value = $vm
$json.parameters.virtualMachineComputerName.value = $vm
$json.parameters.virtualMachineRG.value = $rg
$json.parameters.dataDisks.value[0].name = "$vm`_DataDisk_0"
$json.parameters.dataDiskResources.value[0].name = "$vm`_DataDisk_0"
$json.parameters.dataDiskResources.value[0].properties[0].diskSizeGB = "$disk_size"
$json.parameters.virtualMachineSize.value = $vm_size

$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\server_json\$vm.json"

# New paremeters file with modifications in code
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateParameterFile ".\server_json\$vm.json" -TemplateFile $Template


$Parameters.parameters.virtualMachineName.value = "$vm"
$Parameters.parameters.networkInterfaceName.value = "$vm`_01"

$Parameters | ConvertTo-Json | Out-File -FilePath ".\Parameters.json" -Encoding utf8 -Force
#command to create a V
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $Template_2019 -TemplateParameterFile ".\parameters.json"


#$server_list = gc $(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/server_list.txt
#foreach ($server in $server_list)
#{
#command to create a VM
#}