param location string
param containerregistryname string
param sku string = 'Basic'
param adminUserEnabled bool = true
param anonymousPullEnabled bool = false
param dataEndpointEnabled bool = false

resource ContainerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerregistryname
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    dataEndpointEnabled: dataEndpointEnabled
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}
