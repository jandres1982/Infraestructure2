$server = "zzzwsr9999"
# Write your PowerShell commands here.

#$server_list = gc $(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/server_list.txt
$Parameters_Base = "$(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/parameters.json"

$Template_2019 = "$(System.DefaultWorkingDirectory)/_Infraestructure/ARM_Templates/ARM_VM/TEST/template_2019.json"

##########################################################################
$Parameters = Get-Content $Parameters_Base | out-string | ConvertFrom-Json
$Parameters
#foreach ($server in $server_list)
#{
$Parameters.parameters.virtualMachineName.value = "$server"
$Parameters.parameters.networkInterfaceName.value = "$server`_01"

#command to create a VM
#}