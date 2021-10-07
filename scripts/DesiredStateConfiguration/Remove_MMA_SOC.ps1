Write-Output "Working on Server"
hostname
$workspaceId = "b615f112-4439-41fa-aa80-424be76d309e"
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$mma.RemoveCloudWorkspace($workspaceId)
$mma.ReloadConfiguration()