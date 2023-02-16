@description('Location')
param location string = resourceGroup().location

@description('Network Params')
param networkresourcegroup string
param vnetName string
param subnetNameStorage string

@description('Storage FileShare for IIS Servers')
param project string
var StorageAccountName = 'st${environment}${project}0001'
var fileshare = 'iissharedconf'


@allowed([
  'prod'
  'test'
  'dev'
  'qual'
])
param environment string
var storageAccountSkuName = (environment == 'prod') ? 'Standard_ZRS' : 'Standard_LRS'

module storageaccount 'modules/storageaccount.bicep' = {
  
  name: 'storageaccount'
  params: {
    location: location
    StorageAccountName: StorageAccountName
    storageAccountSkuName: storageAccountSkuName
    fileshare: fileshare
    networkresourcegroup: networkresourcegroup
    vnetName: vnetName
    subnetNameStorage: subnetNameStorage
  }
}
