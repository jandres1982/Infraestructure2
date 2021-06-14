function addWorkID_SoC
{
    $workspaceId = "b615f112-4439-41fa-aa80-424be76d309e"
    $workspaceKey = "xO/JqiWFSYxGY7uIe1XgeFE3LjWFq8jvxoYyLcSGiHNkR/GnDG7eDd1WijUwMD7fW2y8rUnyLeVM8U1s9sDoqQ=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}