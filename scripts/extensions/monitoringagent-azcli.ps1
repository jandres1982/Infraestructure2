##Subscription##
az account set --subscription $(subscription)

#install extension##
az vm extension set -n MicrosoftMonitoringAgent --publisher Microsoft.EnterpriseCloud.Monitoring --version 1.0.18053.0 --vm-name $(vm) --resource-group $(rg) 