function addWorkID_SCC
{
    $workspaceId = "434c56f6-348e-429d-aede-00bb26860a0b"
    $workspaceKey = "dM1GnR5cYcmnCa77mAhAxkFT+7LcMshBDWonxpY3l14UCYYVBHDpz7yc4cUHZnmMKc9JN4p/7SQqY6f5cnVOUg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}
addWorkID_SCC