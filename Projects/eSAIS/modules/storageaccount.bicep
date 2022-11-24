param location string 
param StorageAccountName string 
param blobName string 

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: StorageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'BlockBlobStorage'
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
