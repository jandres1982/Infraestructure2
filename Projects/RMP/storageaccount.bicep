param location string 


@allowed([
  'file'
  'blob'
  'table'
  'queue'
])
param privateLinkGroupId string = 'file'

@description('Storage Account Params')
var StorageAccountName = 'stprodsqlfileshare02'
param storageAccountSkuName string = 'Standard_LRS'

@description('Network params')
param vnetName string = 'EU-PROD-VNET'
param networkresourcegroup string = 'RG_NETWORK_PROD'
param subnetNameStorage string = 'sub-generic-privateendpoints-01'
param privateEndpointName string = 'pe-stprodsqlfileshare02-01'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
  scope: resourceGroup(networkresourcegroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: subnetNameStorage
  parent: vnet
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: StorageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storageaccount.id
          groupIds: [
            privateLinkGroupId
          ]
        }
      }
    ]
  }
}
