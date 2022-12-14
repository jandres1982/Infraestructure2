param location string 
param StorageAccountName string 
param storageAccountSkuName string
param blobName string 

@allowed([
  'file'
  'blob'
  'table'
  'queue'
])
param privateLinkGroupId string = 'blob'

param vnetName string
param networkresourcegroup string
param subnetName string
param privateEndpointName string = 'pe-${StorageAccountName}-01'

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: vnetName
  scope: resourceGroup(networkresourcegroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-05-01' existing = {
  name: subnetName
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
    isHnsEnabled: true
    publicNetworkAccess: 'Disabled'
  }
}

resource blobservice 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  name: 'default'
  parent: storageaccount
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: blobName
  parent: blobservice
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
