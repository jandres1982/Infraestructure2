@description('Location')
param location string = resourceGroup().location

@description('Storage Account Params')
var StorageAccountName = 'sttestlqc0004'
param storageAccountSkuName string = 'Standard_LRS'


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
