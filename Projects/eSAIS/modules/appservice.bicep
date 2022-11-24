param location string
param version string 
param sku string 
param tier string
param kind string
param appServicePlanName  string
param appServiceAppName01 string


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

resource appServiceApp01 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName01
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      linuxFxVersion: version
    }
    httpsOnly: true
  }
}

