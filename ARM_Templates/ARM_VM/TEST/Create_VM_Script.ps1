# Write your PowerShell commands here.
$vm = $args[0]
$rg = $args[1]
#$server_list = gc $(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/server_list.txt
$Parameters_Base = ".\parameters.json"
$Template_2019 = ".\template_2019.json"

#Write-Output $vm

#Write-host $Parameters_Base
##########################################################################
$json = gc $Parameters_Base
$json = $Parameters_Base | convertfrom-json
$json.parameters.virtualMachineName.value = $Vm
$json.parameters.virtualMachineComputerName.value = $Vm
$json.parameters.virtualMachineRG.value = $rg
$json.parameters.networkInterfaceName.value = "$vm`_01"
$json.parameters



#foreach ($server in $server_list)
#{

#$Parameters.parameters.virtualMachineName.value = "$vm"
#$Parameters.parameters.networkInterfaceName.value = "$vm`_01"

#$Parameters | ConvertTo-Json | Out-File -FilePath ".\Parameters.json" -Encoding utf8 -Force

#New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $Template_2019 -TemplateParameterFile ".\parameters.json"

#command to create a VM
#}