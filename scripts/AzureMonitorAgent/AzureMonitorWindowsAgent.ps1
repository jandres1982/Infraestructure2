Select-AzSubscription -Subscription $(sub)
$virtualmachine = Get-AzVM -Name $(vm)
Set-AzVMExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $virtualmachine.resourcegroupname -VMName $virtualmachine.name  -Location $virtualmachine.location  -TypeHandlerVersion "1.17" -EnableAutomaticUpgrade $true