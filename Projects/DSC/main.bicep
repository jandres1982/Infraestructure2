@description('Location.')
param location string = resourceGroup().location

@description('Parameters for App Serviceplan.')
param appServicePlanName string


@description('Parameters for Frontend Web App')
param appName string
param version string 

@description('Log Analytics parameters')
param logAnalyticsName string

@description('Application Insights parameters')
param applicationInsightsName string

@description('Sku and tier for App Service PLan Based on Environment')
@allowed([
  'prod'
  'nonprod'
])
param environment string
var sku = (environment == 'prod') ? 'S1' : 'F1'


module appservice 'modules/appservice.bicep' = {
  name: 'webapp'
  params:{
    location: location
    appServicePlanName: appServicePlanName
    logAnalyticsName: logAnalyticsName
    sku: sku
    applicationInsightsName: applicationInsightsName
    appName: appName
    version: version
  }
}
