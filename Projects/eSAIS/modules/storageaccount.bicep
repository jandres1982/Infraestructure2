param location string 
param StorageAccountName string 
param storageAccountSkuName string = 'Standard_LRS'
param blobName string 
param kind string = 'BlockBlobStorage'
param accessTier string = 'Hot' 

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: StorageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
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
