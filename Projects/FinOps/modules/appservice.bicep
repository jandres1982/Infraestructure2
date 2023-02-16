param location string
param version string 
param sku string 
param tier string
param kind string
param appServicePlanName  string
param appServiceAppName01 string
param appServiceAppName02 string

@description('Network integration parameters')
param networkresourcegroup string
param vnetName string
param subnetNameApp string

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
  scope: resourceGroup(networkresourcegroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: subnetNameApp
  parent: vnet
}

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
    virtualNetworkSubnetId: subnet.id
    siteConfig: {
      vnetRouteAllEnabled: true
      linuxFxVersion: version
    }
    httpsOnly: true
  }
}

resource appServiceApp02 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName02
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: subnet.id
    siteConfig: {
      vnetRouteAllEnabled: true
      linuxFxVersion: version
    }
    httpsOnly: true
  }
}
