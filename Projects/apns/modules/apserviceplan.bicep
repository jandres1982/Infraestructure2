param location string
param sku string 
param tier string
param kind string
param appServicePlanName  string


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
