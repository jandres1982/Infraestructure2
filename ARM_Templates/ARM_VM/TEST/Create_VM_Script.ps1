# Write your PowerShell commands here.

#$server_list = gc $(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/server_list.txt
$Parameters_Base = "./parameters.json"

$Template_2019 = "./template_2019.json"

##########################################################################
$Parameters = Get-Content $Parameters_Base | out-string | ConvertFrom-Json

#foreach ($server in $server_list)
#{
$server = $(vm)
$Resource_group = $(rg)
$Parameters.parameters.virtualMachineName.value = "$server"
$Parameters.parameters.networkInterfaceName.value = "$server`_01"

New-AzResourceGroupDeployment -ResourceGroupName $Resource_group -TemplateFile $Template_2019 -TemplateParameterFile $Parameters

#command to create a VM
#}