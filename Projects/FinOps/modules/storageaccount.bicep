param location string 
param StorageAccountName string 
param storageAccountSkuName string
param blobName string 

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
