function addWorkID_SCC
{
    $workspaceId = "fa488d5a-d8e4-4437-9ccc-2ef59e9eb669"
    $workspaceKey = "1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}
addWorkID_SCC