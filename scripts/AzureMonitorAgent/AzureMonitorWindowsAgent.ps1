#Install
Set-AzVMExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName "RG-CIS-PROD-WSUSSERVER-01"  -VMName "shhwsr1238" -Location "NorthEurope" -TypeHandlerVersion "1.14" -EnableAutomaticUpgrade $true

#Remove the old one
Remove-AzVMExtension -Name Microsoft.Insights.LogAnalyticsAgent -ResourceGroupName "RG-CIS-PROD-WSUSSERVER-01"  -VMName "shhwsr1238" -Confirm:$false -force
Remove-AzVMExtension -Name MicrosoftMonitoringAgent -ResourceGroupName "RG-GIS-PROD-SCRIPTINGSERVER-01"  -VMName "shhwsr1849" -Confirm:$false -force