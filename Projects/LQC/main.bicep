@description('Parameter for App Service Plan')
param location string = resourceGroup().location
param hostingPlanName string


@description('Parameters for Web App')
param functionAppName string

@description('The name of ApplicationInsights')
param applicationInsightsName string

@description('Storage Account name')
param storageAccountName string
param storageAccountType string

@description('Select the configuration of service plan based on environment')
@allowed([
  'prod'
  'nonprod'
])
param environment string
var sku = (environment == 'prod') ? 'S1' : 'Free'
var tier = (environment == 'prod') ? 'Standard' : 'Free'

module functionapp 'modules/functionapp.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    hostingPlanName: hostingPlanName
    sku: sku
    tier: tier
    functionAppName: functionAppName
    applicationInsightsName: applicationInsightsName
    storageAccountName: storageAccountName
  }
}

module storageAccount 'modules/storageaccount.bicep' = {
  name: 'storageaccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: storageAccountType
  }
}
