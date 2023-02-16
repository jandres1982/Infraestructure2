@description('Location.')
param location string = resourceGroup().location

@description('Parameters for App Serviceplan.')
param appServicePlanName string
param sku string 
param tier string
param kind string

@description('Parameters for Frontend Web App')
param appFrontendName string
param versionFrontend string 

@description('Parameters for Backend Web App')
param appBackendName string
param versionBackend string 

module appServices 'modules/appservices.bicep' = {
  name: 'appServices'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    sku: sku
    tier: tier
    kind: kind
    appFrontendName: appFrontendName
    versionFrontend: versionFrontend
    appBackendName: appBackendName
    versionBackend: versionBackend
  }
}

@description('Parameters for StorageAccount.')
param StorageAccountName string 
param blobName string 

@allowed([
  'prod'
  'nonprod'
])
param environment string
var storageAccountSkuName = (environment == 'prod') ? 'Standard_ZRS' : 'Standard_LRS'
module storageaccount 'modules/storageaccount.bicep' = {
  name: 'storageaccount'
  params: {
    location: location
    StorageAccountName: StorageAccountName
    storageAccountSkuName: storageAccountSkuName
    blobName: blobName
  }
}

@description('Parameters for KeyVault')
param keyvaultname string
module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params:{
    keyvaultname: keyvaultname
    location: location
  }  
}