function addWorkID_MIG
{
    $workspaceId = "a054b1bf-24eb-4e0b-a7e6-0fb782e77bf6"
    $workspaceKey = "d/DAXhGLEcj+D+QNvTQj84jWCEcAb+jsn/37lroX0zjfBEQBIOppTeIglpqCeCHz6a/XXcyY8QgUvmrOkV+dmg=="
    $mma1 = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
    $mma1.AddCloudWorkspace($workspaceId, $workspaceKey)
    $mma1.ReloadConfiguration()
}
addWorkID_MIG