param location string = resourceGroup().location

@description('App Param')
param project string
param version string 
param sku string 
param tier string
param kind string

@description('Schindler Naming variables for Web Service')
var appServicePlanName  = 'asp-${environment}-${project}-01'
var appServiceAppName01 = 'app-${environment}-${project}-01'

@allowed([
  'prod'
  'test'
  'dev'
  'qual'
])
param environment string

module appService 'modules/appservice.bicep' = {
    name: 'appService'
    params: {
      location: location
      appServiceAppName01: appServiceAppName01
      appServicePlanName: appServicePlanName
      sku: sku
      tier: tier
      version: version
      kind: kind
    }
}
