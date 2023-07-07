@description('Location')
param location string = resourceGroup().location

@description('Storage Account naming')
var StorageAccountName = 'st${environment}${project}01'

@allowed([
  's-sis-eu-nonprod-01'
  's-sis-eu-prod-01'
])
param sub string

@allowed([
  'prod'
  'test'
  'dev'
  'qual'
  'nonprod'
])
param environment string
param project string
var storageAccountSkuName = (environment == 'prod') ? 'Standard_ZRS' : 'Standard_LRS'

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
    minimumTlsVersion: 'TLS1_2'
  }
}
