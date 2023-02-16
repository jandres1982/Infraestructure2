param location string
param postgressql string
param backupRetentionDays int = 7
param storageSizeGB int = 100
param administratorLogin string
@secure()
param administratorLoginPassword string

resource postgressqlflexibleserver 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: postgressql
  location: location
  sku: {
    name: postgressql
    tier: 'GeneralPurpose'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: '3'
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: 'Disable'
    }
    createMode: 'Create'
    highAvailability: {
      mode: 'Disable'
    }
    maintenanceWindow: {
      customWindow: 'Disable'

    }
    storage: {
      storageSizeGB: storageSizeGB
    }
    version: '14'
  }
}
