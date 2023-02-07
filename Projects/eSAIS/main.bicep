@description('Deployment Location')
param location string = resourceGroup().location

@description('Network parametets for Azure Spring App')
param networkresourcegroup string
param vnetName string
param subnetName01 string
param subnetName02 string

@description('Project Param')
param project string


@description('Schindler Spring App Service Schinler Naming Variables')
var springCloudInstanceName = 'asa-${environment}-${project}-01'
var loganalytics = 'log-${environment}-${project}-01'
var appInsightsName = 'appi${environment}-${project}-01'


@allowed([
  'prod'
  'test'
  'dev'
  'qual'
  'nonprod'
])
param environment string

module springapp 'modules/appsrping.bicep' = {
  name: 'springapp'
  params: {
    location: location
    appInsightsName: appInsightsName
    loganalytics: loganalytics
    springCloudInstanceName: springCloudInstanceName
    networkresourcegroup: networkresourcegroup
    vnetName: vnetName
    subnetName01: subnetName01
    subnetName02: subnetName02
  }
}
