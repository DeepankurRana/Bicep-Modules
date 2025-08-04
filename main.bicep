targetScope = 'resourceGroup'

@description('Required. The name of the static web app.')
param staticWebAppName string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Environment name (e.g., dev, test, prod).')
param environment string = 'dev'

@description('Optional. Tags to apply to all resources.')
param tags object = {}

@description('Required. The URL of the Azure DevOps repository.')
param repositoryUrl string

@description('Optional. The branch name of the repository.')
param branch string = 'main'

@secure()
@description('Optional. The Personal Access Token for accessing the Azure DevOps repository.')
param repositoryToken string?

@description('Optional. The service tier and name of the resource SKU.')
@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Optional. Custom domain name for the static web app.')
param customDomainName string?

@description('Optional. Build properties for the static site.')
param buildProperties object = {
  appLocation: '/'
  apiLocation: ''
  outputLocation: ''
}

@description('Optional. Whether or not public network access is allowed for this resource.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

// Create common tags
var commonTags = union(tags, {
  Environment: environment
  DeployedBy: 'Bicep'
  Application: 'StaticWebApp'
})

// Deploy the static web app using the module
module staticWebApp 'staticWebApp.bicep' = {
  name: 'staticWebApp-${uniqueString(resourceGroup().id)}'
  params: {
    name: staticWebAppName
    location: location
    tags: commonTags
    sku: sku
    repositoryUrl: repositoryUrl
    branch: branch
    repositoryToken: repositoryToken
    buildProperties: buildProperties
    customDomainName: customDomainName
    publicNetworkAccess: publicNetworkAccess
    managedIdentities: {
      systemAssigned: true
    }
    provider: 'DevOps'
    allowConfigFileUpdates: true
    stagingEnvironmentPolicy: 'Enabled'
  }
}

// Outputs
@description('The name of the deployed static web app.')
output staticWebAppName string = staticWebApp.outputs.name

@description('The resource ID of the deployed static web app.')
output staticWebAppResourceId string = staticWebApp.outputs.resourceId

@description('The default hostname of the static web app.')
output defaultHostname string = staticWebApp.outputs.defaultHostname

@description('The principal ID of the system assigned managed identity.')
output systemAssignedMIPrincipalId string = staticWebApp.outputs.systemAssignedMIPrincipalId

@description('The deployment token for CI/CD integration.')
@secure()
output deploymentToken string = staticWebApp.outputs.deploymentToken

@description('The resource group name where the static web app was deployed.')
output resourceGroupName string = staticWebApp.outputs.resourceGroupName

@description('The location where the static web app was deployed.')
output location string = staticWebApp.outputs.location