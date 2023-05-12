https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.compute/vm-domain-join/main.bicep


- If para zonas 
- extension
- if para st account de diagnostics (partially done)
- if para los rg de las virtual networks (partially done)
- if version OS (done)
- rellenar parameters file

- join domain (global, dmz, tstglobal)

az cloud list --output table
az cloud set --name AzureCloud
az deployment group create --resource-group rg-cis-prod-server-01 --template-file main_v1_cn.bicep
10.76.4.198