param location string = resourceGroup().location

@description('Network Params')
param networkresourcegroup string
param vnetName string
param subnetNameStorage string
param subnetNameApp string

@description('App Param')
param project string
param version string 
param sku string 
param tier string
param kind string

@description('Schindler Naming variables for Web Service')
var appServicePlanName  = 'asp-${environment}-${project}-01'
var appServiceAppName01 = 'app-${environment}-${project}-01'
var appServiceAppName02 = 'app-${environment}-${project}-02'


@description('Schindler Naming variables for Function App Service')
var storageAccountFunctionName = 'st${environment}${project}0002'
var appServiceFunctionPlanName = 'asp-${environment}-${project}-02'
var functionAppName = 'fa-${environment}-${project}-01'

@description('Schindler Naming variables for Data Factory')
var datafactoryname = 'adf-${environment}-${project}-01'

@description('Storage Account Param Data Lake')
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
    networkresourcegroup: networkresourcegroup
    vnetName: vnetName
    subnetNameStorage: subnetNameStorage
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
      networkresourcegroup: networkresourcegroup
      vnetName: vnetName
      subnetNameApp: subnetNameApp
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

module datafactory 'modules/datafactory.bicep' = {
  name: 'datafactory'
  params: {
    location: location
    datafactoryname: datafactoryname
  }
}
