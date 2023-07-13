#waf
#config
$sub = "s-sis-eu-prod-01"
$rg = "RG_NETWORK_PROD"
$policy = "3dexcite"

Select-AzSubscription -Subscription $sub
$AppGW = Get-AzApplicationGateway -Name "agw-prod-network-shhnag0001" -ResourceGroupName "RG_NETWORK_PROD"
$FirewallConfig = Get-AzApplicationGatewayWebApplicationFirewallConfiguration -ApplicationGateway $AppGW

az login
az account set --subscription $sub
$Policy_Waf_Config = az network application-gateway waf-policy managed-rule rule-set list --policy-name $policy --resource-group $rg
$Pol = $Policy_Waf_Config | ConvertFrom-Json