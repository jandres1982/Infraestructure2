@description('Deployment Location')
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

@description('Schindler Spring App Service Schinler Naming Variables')
var springCloudInstanceName = 'asa-${environment}-${project}-01'
var loganalytics = 'log-${environment}-${project}-01'
var appInsightsName = 'appi${environment}-${project}-01'

@description('Storage Account Param')
var StorageAccountName = 'st${environment}${project}0001'
param blobName string = 'eSAIS'

@allowed([
  'prod'
  'test'
  'dev'
  'qual'
])
param environment string
param storageAccountSkuName string

module appService 'modules/appservice.bicep' = {
  name: 'appService'
  params: {
    location: location
    appServiceAppName01: appServiceAppName01
    appServicePlanName: appServicePlanName
    kind: kind
    sku: sku
    tier: tier
    version: version
  }
}

module storageaccount 'modules/storageaccount.bicep' = {
  name: 'storageaccount'
  params: {
    location: location
    StorageAccountName: StorageAccountName
    storageAccountSkuName: storageAccountSkuName
    blobName: blobName
  }
}

module springapp 'modules/appsrping.bicep' = {
  name: 'springapp'
  params: {
    location: location
    appInsightsName: appInsightsName
    loganalytics: loganalytics
    springCloudInstanceName: springCloudInstanceName
  }
}
