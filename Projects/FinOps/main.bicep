param location string = resourceGroup().location

@description('App Param')
param project string
param version string 
param sku string 
param tier string
param kind string

@description('Schindler Naming variabls for Web Service')
var appServicePlanName  = 'asp-${environment}-${project}-01'
var appServiceAppName01 = 'app-${environment}-${project}-01'
var appServiceAppName02 = 'app-${environment}-${project}-02'

@description('Schindler Naming variables for KeyVault')
param objectId string
var keyvaultname = 'kv-${environment}-${project}-01'

@description('Schindler Naming variables for Function App Service')
var storageAccountFunctionName = 'st${environment}${project}0002'
var appServiceFunctionPlanName = 'asp-${environment}-${project}-02'
var functionAppName = 'fa-${environment}-${project}-01'


@description('Storage Account Param')
var StorageAccountName = 'st${environment}${project}0001'
param blobName string 

@allowed([
  'prod'
  'test'
  'dev'
  'qual'
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

module appService 'modules/appservice.bicep' = {
    name: 'appService'
    params: {
      location: location
      appServiceAppName01: appServiceAppName01
      appServiceAppName02: appServiceAppName02
      appServicePlanName: appServicePlanName
      sku: sku
      tier: tier
      version: version
      kind: kind
    }
}

module keyvault 'modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    keyvaultname: keyvaultname
    objectId: objectId
  }
}

module funtionapp 'modules/functionapp.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    storageAccountFunctionName: storageAccountFunctionName
    appServiceFunctionPlanName: appServiceFunctionPlanName
    functionAppName: functionAppName
  }
}
