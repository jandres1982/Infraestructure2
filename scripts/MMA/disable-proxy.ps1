$healthServiceSettings = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$proxyMethod = $healthServiceSettings | Get-Member -Name 'SetProxyInfo'
$healthServiceSettings.SetProxyInfo('', '', '')