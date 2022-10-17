@description('Location.')
param location string

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

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku:{
    tier: tier
    name: sku
  }
  kind: kind
}

resource appFrontend 'Microsoft.Web/sites@2022-03-01' = {
  name: appFrontendName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      linuxFxVersion: versionFrontend
    }
    httpsOnly: true
  }
}

resource appBackend 'Microsoft.Web/sites@2022-03-01' = {
  name: appBackendName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      linuxFxVersion: versionBackend
    }
    httpsOnly: true
  }
}
