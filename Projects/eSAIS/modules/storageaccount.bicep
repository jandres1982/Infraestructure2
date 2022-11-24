param location string 
param StorageAccountName string 


resource storageaccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: StorageAccountName
  location: location
  sku: {
    name: 'Premium_LRS'
  }
  kind: 'BlockBlobStorage'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    isHnsEnabled: true
    publicNetworkAccess: 'Disabled'
  }
}
