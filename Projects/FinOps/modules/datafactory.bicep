param location string
param datafactoryname string

resource symbolicname 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: datafactoryname
  location: location
  properties: {
    globalParameters: {}
    publicNetworkAccess: 'Disabled'
  }
}
