@description('Deployment Location')
param location string = resourceGroup().location

@description('Network parametets for Private Endpoint')
param networkresourcegroup string
param vnetName string
param subnetName string
@allowed([
  'file'
  'blob'
  'table'
  'queue'
])
param privateLinkGroupId string = 'file'
var privateEndpointName = 'pe-${StorageAccountName}-01'

@description('Storage Account Parameters') 
var StorageAccountName = 'st${environment}${project}0001'
param FileShareName string
@allowed([
  'prod'
  'test'
  'dev'
  'qual'
])
param environment string
param project string
var storageAccountSkuName = (environment == 'prod') ? 'Standard_ZRS' : 'Standard_LRS'

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
    publicNetworkAccess: 'Disabled'
  }
}

resource fileservice 'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = {
  name: 'default'
  parent: storageaccount
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  name: FileShareName
  parent: fileservice
  properties: {
    accessTier: 'hot'
    enabledProtocols: 'smb'
    shareQuota: 2048
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
