@description('Location.')
param location string

@description('Parameters for App Serviceplan.')
param appServicePlanName string
param sku string 



@description('Parameters for Frontend Web App')
param appName string
param version string 

@description('Log Analytics parameters')
param logAnalyticsName string

@description('Application Insights parameters')
param applicationInsightsName string


resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku:{
    name: sku
  }
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      netFrameworkVersion: version
    }
    httpsOnly: true
  }
  dependsOn: [
    loganalytics
  ]
}

resource appServiceLogging 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appService
  name: 'appsettings'
  properties: {
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
  }
  dependsOn: [
    appServiceSiteExtension
  ]
}

resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = {
  parent: appService
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
  dependsOn: [
    applicationInsights
  ]
}

resource loganalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    }
  }


resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    WorkspaceResourceId: loganalytics.id
  }
}
