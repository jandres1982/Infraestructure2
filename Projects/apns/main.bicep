param location string = resourceGroup().location
@allowed([
  'prod'
  'test'
  'dev'
  'qual'
])
param environment string
@description('Schindler naming variables for Postgres SQL Service')
param project string
param administratorLogin string
@secure()
param administratorLoginPassword string
var postgresservername  = 'psql-${environment}-${project}-01'

module postgressql 'modules/postgressql.bicep' = {
  name: 'postgres'
  params: {
    location: location
    postgresservername: postgresservername
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

@description('Schindler naming App Service Plan')
param sku string 
param tier string
param kind string
var appServicePlanName = 'asp-${environment}-${project}-01'

module appserviceplan 'modules/apserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    location: location
    sku: sku
    tier: tier
    kind: kind
    appServicePlanName: appServicePlanName
  }
}

@description('Schindler naming Container Registry')
var containerregistryname = 'cr${environment}${project}01'

module containerregistry 'modules/containerregistry.bicep' = {
  name: containerregistryname
  params: {
    location: location
    containerregistryname: containerregistryname
  }
}
