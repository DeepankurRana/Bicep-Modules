@description('Required. The name of the static site.')
@minLength(1)
@maxLength(40)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@allowed([
  'Free'
  'Standard'
])
@description('Optional. The service tier and name of the resource SKU.')
param sku string = 'Free'

@description('Optional. False if config file is locked for this static web app; otherwise, true.')
param allowConfigFileUpdates bool = true

@allowed([
  'Enabled'
  'Disabled'
])
@description('Optional. State indicating whether staging environments are allowed or not allowed for a static web app.')
param stagingEnvironmentPolicy string = 'Enabled'

@allowed([
  'Disabled'
  'Disabling'
  'Enabled'
  'Enabling'
])
@description('Optional. State indicating the status of the enterprise grade CDN serving traffic to the static web app.')
param enterpriseGradeCdnStatus string = 'Disabled'

@description('Optional. Build properties for the static site.')
param buildProperties object = {
  appLocation: '/'
  apiLocation: ''
  outputLocation: ''
}

@description('Optional. Template Options for the static site.')
param templateProperties object?

@description('Optional. The provider that submitted the last deployment to the primary environment of the static site.')
param provider string = 'DevOps'

@secure()
@description('Optional. The Personal Access Token for accessing the Azure DevOps repository.')
param repositoryToken string?

@description('Required. The URL of the Azure DevOps repository.')
param repositoryUrl string

@description('Optional. The branch name of the repository.')
param branch string = 'main'

import { managedIdentityAllType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. The managed identity definition for this resource. System identity will be enabled by default.')
param managedIdentities managedIdentityAllType = {
  systemAssigned: true
}

import { roleAssignmentType } from 'br/public:avm/utl/types/avm-common-types:0.5.1'
@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

@description('Optional. Custom domain name for the static web app.')
param customDomainName string?

@description('Optional. Custom domain validation method. If not specified, automatically determined based on domain structure.')
@allowed([
  'dns-txt-token'
  'cname-delegation'
])
param validationMethod string = 'cname-delegation'

@description('Optional. Whether or not public network access is allowed for this resource.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

// Ensure system identity is always enabled
var finalManagedIdentities = union(managedIdentities, {
  systemAssigned: true
})

var formattedUserAssignedIdentities = reduce(
  map((finalManagedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
)

var identity = {
  type: (finalManagedIdentities.?systemAssigned ?? true)
    ? (!empty(finalManagedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
    : (!empty(finalManagedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'SystemAssigned')
  userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
}

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
  'Web Plan Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '2cc479cb-7b4d-49a8-b449-8c00fd0f0a4b'
  )
  'Website Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'de139f84-1756-47ae-9be6-808fbbe84772'
  )
  'Static Web Apps Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '41077137-e803-4205-871c-5a86e6a753b4'
  )
}

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

resource staticSite 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    allowConfigFileUpdates: allowConfigFileUpdates
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    enterpriseGradeCdnStatus: enterpriseGradeCdnStatus
    provider: provider
    branch: branch
    buildProperties: buildProperties
    repositoryToken: repositoryToken
    repositoryUrl: repositoryUrl
    templateProperties: templateProperties
    publicNetworkAccess: publicNetworkAccess
  }
}

resource staticSite_customDomains 'Microsoft.Web/staticSites/customDomains@2024-04-01' = if (!empty(customDomainName)) {
  name: customDomainName!
  parent: staticSite
  properties: {
    validationMethod: validationMethod
  }
}

resource staticSite_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(staticSite.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: staticSite
  }
]

@description('The name of the static site.')
output name string = staticSite.name

@description('The resource ID of the static site.')
output resourceId string = staticSite.id

@description('The resource group name.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = staticSite.location

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = staticSite.identity.principalId

@description('The name of the static site custom domain.')
output customDomainName string = !empty(customDomainName) ? staticSite_customDomains.name : ''

@description('The resource ID of the static site custom domain.')
output customDomainResourceId string = !empty(customDomainName) ? staticSite_customDomains.id : ''

@description('The default hostname of the static site.')
output defaultHostname string = staticSite.properties.defaultHostname

@description('The deployment token for the static site (used for CI/CD).')
@secure()
output deploymentToken string = listSecrets(staticSite.id, staticSite.apiVersion).properties.apiKey