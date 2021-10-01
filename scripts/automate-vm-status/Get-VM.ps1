#Post_migration_task_Microsoft_Monitoring_Agent.
function RemoveWorkID_MIG
{
$workspaceId = "a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6"
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.RemoveCloudWorkspace($workspaceId)
$mma.ReloadConfiguration()
}

function Remove_proxy
{
param($ProxyDomainName="")

# First we get the Health Service configuration object.  We need to determine if we
# have the right update rollup with the API we need.  If not, no need to run the rest of the script.
$healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'
if (!$proxyMethod)
{
    Write-Output 'Health Service proxy API not present, will not update settings.'
    return
}
Write-Output "Clearing proxy settings."
$healthServiceSettings.SetProxyInfo('', '', '')

}

function addWorkID_SoC
{
    $workspaceId = "b615f112-4439-41fa-aa80-424be76d309e"
    $workspaceKey = "xO/JqiWFSYxGY7uIe1XgeFE3LjWFq8jvxoYyLcSGiHNkR/GnDG7eDd1WijUwMD7fW2y8rUnyLeVM8U1s9sDoqQ=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}

function addWorkID_SCC
{
    $workspaceId = "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"
    $workspaceKey = "1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}

Function Check_WID_Provided
{
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.GetCloudWorkspaces()
$WID = $mma.GetCloudWorkspaces()
}

Select-AzSubscription -Subscription "s-sis-eu-nonprod-01"
$VM_EU_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_nonProd.txt
Select-AzSubscription -Subscription "s-sis-eu-prod-01"
$VM_EU_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_eu_Prod.txt
Select-AzSubscription -Subscription "s-sis-ap-prod-01"
$VM_AP = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_Prod.txt
Select-AzSubscription -Subscription "s-sis-am-prod-01"
$VM_AM_Prod = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_ap.txt
Select-AzSubscription -Subscription "s-sis-am-nonprod-01"
$VM_AM_NonProd = $(get-azvm).name | where-object {$_ -like '*wsr*'} > .\servers_list_am_nonProd.txt

$file = Get-Content .\servers_list_eu_nonProd.txt
Write-Output $file 
