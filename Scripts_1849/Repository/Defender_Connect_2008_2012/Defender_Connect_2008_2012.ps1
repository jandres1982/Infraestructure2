#Make TLS 1.2 is being used for Powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Before using Azure PowerShell to manage VM extensions on your hybrid server managed by Azure Arc-enabled servers, you need to install the Az.ConnectedMachine module. Run the following command on your Azure Arc-enabled server:
install-module -Name Az.ConnectedMachine
Import-Module -name Az.ConnectedMachine

# specify location, resource group, and VM for the extension
$location = "northeurope" # eg., “Southeast Asia” or “Central US”
$resourceGroupName = "rg-shh-prod-defendersecurity-01"
$machineName = "shhwsr0579"
$subscriptionid ="505ead1a-5a5f-4363-9b72-83eb2234a43d”

Connect-AzAccount # Will be prompted to login with a proper account to azure
# Enable Antimalware with default policies
$settingString = ‘{"AntimalwareEnabled": true}’;
New-AzConnectedMachineExtension -Name "IaaSAntimalware" -ResourceGroupName $resourceGroupName -MachineName $machineName -Location $location -SubscriptionId $subscriptionid -Publisher “Microsoft.Azure.Security” -Settings $settingString -ExtensionType “IaaSAntimalware”