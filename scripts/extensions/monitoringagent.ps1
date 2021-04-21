##Subscription##
$subscription = "s-sis-eu-prod-01"
az account set --subscription $subscription

$rg = "rg-cis-prod-server-01"
$vm = "SHHWSR1999"

#install extension##
az vm extension set -n MicrosoftMonitoringAgent --publisher Microsoft.EnterpriseCloud.Monitoring --version 1.0.18053.0 --vm-name $vm --resource-group $rg 