echo "$(workspaceId)"
#$PublicSettings = @{"workspaceId" = $(workspaceId)}
#$ProtectedSettings = @{"workspaceKey" = $(workspaceKey)}
#fa488d5a-d8e4-4437-9ccc-2ef59e9eb669
#1DxbXeHBAM3QLWl4GcE9SF0eTCEYuyr5pAt5k3wGG+bASH/ug9XGmVUyHKGvi/nmVIAYLLvfemwkuhM0yxGWCA==
#Set-AzVMExtension -ExtensionName "MicrosoftMonitoringAgent" `
#    -ResourceGroupName $(rg) `
#    -VMName $(vm) `
#    -Publisher "Microsoft.EnterpriseCloud.Monitoring" `
#    -ExtensionType "MicrosoftMonitoringAgent" `
#    -TypeHandlerVersion 1.0 `
#    -Settings $PublicSettings `
#    -ProtectedSettings $ProtectedSettings `
#    -Location NorthEurope