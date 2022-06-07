
$url='https://dev.azure.com/devsdb'

$token='v2gy4wi2w3ytal757d5gmx2wyjp3vvhgpraoj3bxpj7sluybgj4q'

$agent_name='dockeragent01'

$agent_pool='SIS-IOC-Azure'

az container create --resource-group "rg-shh-prod-devopsagents-01" --name $agent_name --image "crproddevopsagents01.azurecr.io/dockeragents:v2.0" --restart-policy OnFailure --os-type Windows --cpu 1 --memory 2 --registry-login-server "crproddevopsagents01.azurecr.io" --registry-username "crproddevopsagents01" --registry-password "+UCTOg/5NvsjvY4dD374PJ4BohAQmuOY" --secure-environment-variables AZP_TOKEN=$token --environment-variables AZP_URL=$url AZP_POOL=$agent_pool AZP_AGENT_NAME=$agent_name