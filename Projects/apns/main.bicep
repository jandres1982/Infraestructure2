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
