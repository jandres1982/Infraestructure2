New-Item -Path ".\MMA_Json" -ItemType "Directory" -Force
$vm = $args[0]
$Parameters_Base = ".\parameters-eu.json"
$Template = ".\template.json"
$json = Get-Content $Parameters_Base -raw | convertfrom-json
$json.parameters.vmName[0].value = "$vm"
$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\MMA_Json\$vm.json"
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateParameterFile ".\MMA_Json\$vm.json" -TemplateFile $Template
Write-Host "No agent was found in $vm, but now should be enable"

#In PowerShell As an Administrator go to this path “C:\Program Files\Microsoft Monitoring Agent\Agent\Troubleshooter” and run the script “GetAgentInfo.PS1” and choose option “Collect all logs”
