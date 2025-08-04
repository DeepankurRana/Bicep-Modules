targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

@description('Required. Azure location to which the resources are to be deployed -defaults to the location of the resource group')
param location string

@description('Required. A short name for the workload being deployed')
param workloadName string

@description('Required. A short name for the organization name deploying resources')
param organizationName string

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Required. The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'test'
])
param environment string

param storageaccountname string = 'stgdsctest'

param storageAccountResourceGroup string = 'bicep-grp'

@secure()
@description('Primary key of the storage account.')
param storageAccountKey string


@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

// ------------------
// VARIABLES
// ------------------

var defaultSuffixes = [
  location
  organizationName
  workloadName
  environment
]
var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [numericSuffix])

module naming 'bicep/modules/naming.bicep' = {
  name: 'namingModule-Deployment'
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

var resourcesNaming = naming.outputs.names

// ------------------
// AIFoundry Deployment
// ------------------

module AIFoundry 'bicep/modules/AIfoundry.bicep' = {
  name: 'ai-${uniqueString(resourceGroup().id)}'
  params: {
    name: resourcesNaming.aifoundry.name
    location: location
    tags: tags
    skuName: 'S0'
    kind: 'AIServices'
    publicNetworkAccess: 'Enabled'
    defaultProject: 'ai-swc-mc-test-dealmech-project'
    associatedProjects: [
      'ai-swc-mc-test-dealmech-project'
    ]
    customSubDomainName: resourcesNaming.aifoundry.name
    allowedFqdnList: []
    restore: false
    restrictOutboundNetworkAccess: true
    userOwnedStorage: null
    roleAssignments: []
    deploymentName: '${resourcesNaming.aifoundry.name}-deploy'
    projectname: 'ai-swc-mc-test-deal-project'
    modelName: 'gpt-4.1-mini'
    modelVersion: '2025-04-14'
    capacity: 200
    raiPolicyName: 'Microsoft.DefaultV2'
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    storageaccountname: storageaccountname
    storageAccountResourceGroup: storageAccountResourceGroup
    storageAccountKey: storageAccountKey

    //mode: 'Blocking'
    //basePolicyName: 'Microsoft.Default'
    //blocking: true
    //enabled: true
    //severityThreshold: 'Medium'
    //source: 'Prompt'
  }
}
