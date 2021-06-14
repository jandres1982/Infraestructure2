$Parameters_Base = ".\parameters_SOC.json"
$Template = ".\template.json"
$servers = Get-Content ".\Server_List.txt"
New-Item -ItemType directory -Path ".\MMA_Json_SOC" -ErrorAction SilentlyContinue
foreach ($server in $servers)
{
$json = Get-Content $Parameters_Base -raw | convertfrom-json
$json.parameters.vmName[0].value = "$server"
$json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\MMA_Json_SOC\$server.json"
$rg = $(Get-AzVM -Name $server).ResourceGroupName
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateParameterFile ".\MMA_Json_SOC\$server.json" -TemplateFile $Template
}