@description('The instance name of the Azure Spring Cloud resource')
param springCloudInstanceName string

@description('The name of the Application Insights instance for Azure Spring Cloud')
param appInsightsName string

@description('The resource ID of the existing Log Analytics workspace. This will be used for both diagnostics logs and Application Insights')
param loganalytics string

param location string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: loganalytics
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    }
  }

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource springCloudInstance 'Microsoft.AppPlatform/Spring@2022-03-01-preview' = {
  name: springCloudInstanceName
  location: location
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}
  

resource springCloudMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
  name: '${springCloudInstance.name}/default' // The only supported value is 'default'
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: appInsights.properties.InstrumentationKey
  }
}

resource springCloudDiagnostics 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'monitoring'
  scope: springCloudInstance
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
  }
}
