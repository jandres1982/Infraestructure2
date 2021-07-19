$Parameters_Base = ".\parameters-ap.json"
$Template = ".\template.json"
$servers = Get-Content ".\Server_List.txt"
New-Item -ItemType directory -Path ".\MMA_Json" -ErrorAction SilentlyContinue
foreach ($server in $servers)
{
$rg = $(Get-AzVM -Name $server).ResourceGroupName

if (Get-AzVMExtension -ResourceGroupName $rg -VMName $server -Name "MicrosoftMonitoringAgent" -ErrorAction SilentlyContinue)
{
    write-host "This $server has the monitor agent skipping the installation"
}
else
{
    $json = Get-Content $Parameters_Base -raw | convertfrom-json
    $json.parameters.vmName[0].value = "$server"
    $json | ConvertTo-Json -Depth 32 | Out-File -encoding "UTF8" -FilePath ".\MMA_Json\$server.json"
    New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateParameterFile ".\MMA_Json\$server.json" -TemplateFile $Template
    Write-Host "No agent was found in $server, but now should be enable"
}
}