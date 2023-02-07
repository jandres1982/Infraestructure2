param location string 
param StorageAccountName string 
param storageAccountSkuName string
param fileshare string 

@allowed([
  'file'
  'blob'
  'table'
  'queue'
])
param privateLinkGroupId string = 'file'

param vnetName string
param networkresourcegroup string
param subnetNameStorage string
param privateEndpointName string = 'pe-${StorageAccountName}-01'

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

resource fileservice 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storageaccount
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: fileshare
  parent: fileservice
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
