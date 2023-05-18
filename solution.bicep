targetScope = 'subscription'

@allowed([
  'AvailabilitySet'
  'AvailabilityZones'
  'None'
])
@description('Set the desired availability / SLA with a pooled host pool.  Choose "None" if deploying a personal host pool.')
param Availability string = 'None'

@description('If using availability sets, enter the name prefix for the resources.')
param AvailabilitySetNamePrefix string = ''

@description('If using availability zones, enter the desired zones for the AVD session hosts.')
param AvailabilityZones array = [
  '1'
]

@description('If using Server Side Encryption, enter the resource ID for the disk encryption set.')
param DiskEncryptionSetResourceId string = ''

@secure()
@description('If domain or hybrid joining the session hosts, input the password for the principal that will join the hosts to the domain.')
param DomainPassword string

@allowed([
  'ActiveDirectory' // Active Directory Domain Services or Azure Active Directory Domain Services
  'None' // Azure AD Join
  'NoneWithIntune' // Azure AD Join with Intune enrollment
])
@description('The service providing domain services for Azure Virtual Desktop.')
param DomainServices string = 'ActiveDirectory'

@secure()
@description('If domain or hybrid joining the session hosts, input the user principal name for the principal that will join the hosts to the domain.')
param DomainUserPrincipalName string

@description('Enter the resource ID for the existing AVD host pool.')
param HostPoolResourceId string

@maxLength(24)
@minLength(3)
@description('Enter the name of the Azure key vault.')
param KeyVaultName string = 'kv-avd-d-use'

@secure()
@description('Enter the local administrator password for the AVD session hosts.')
param LocalAdminPassword string

@secure()
@description('Enter the local administrator username for the AVD session hosts.')
param LocalAdminUsername string

@description('Location for all the deployed resources and resource group.')
param Location string = deployment().location

@description('Enter the name of the new resource group that will be deployed with this solution')
param ResourceGroupName string = 'rg-avd-d-use'

@description('Enter an array of Object IDs for the security principals to assign to the Key Vault for template spec deployments.')
param SecurityPrincipalObjectIds array

@description('Enter the location for the AVD session hosts.')
param SessionHostLocation string

@description('The distinguished name for the target Organization Unit in Active Directory Domain Services.')
param SessionHostOuPath string = ''

@description('Enter the resource group name for the AVD session hosts.')
param SessionHostResourceGroupName string

@description('Enter the resource ID for the target subnet for the AVD session hosts.')
param SubnetResourceId string

@description('The key / value pairs of metadata for the Azure resources.')
param Tags object = {}

@description('Enter the name for the template spec.')
param TemplateSpecName string = 'ts-avd-d-use'

@description('Enter the version number for the template spec version')
param TemplateSpecVersion string = '1.0'

@description('DO NOT MODIFY THIS VALUE! The timestamp is needed to differentiate deployments for certain Azure resources and must be set using a parameter.')
param Timestamp string = utcNow('yyyyMMddhhmmss')

resource rg 'Microsoft.Resources/resourceGroups@2020-10-01' = {
  name: ResourceGroupName
  location: Location
  tags: Tags
}

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(subscription().id, 'CaseWorkerDeploy')
  properties: {
    roleName: 'KeyVaultDeployAction_${subscription().subscriptionId}'
    description: 'Allows a principal to get but not view Key Vault secrets for an ARM template deployment.'
    assignableScopes: [
      subscription().id
    ]
    permissions: [
      {
        actions: [
          'Microsoft.KeyVault/vaults/deploy/action'
        ]
      }
    ]
  }
}

module keyVault 'modules/keyVault.bicep' = {
  scope: rg
  name: 'KeyVault_${Timestamp}'
  params: {
    DomainPassword: DomainPassword
    DomainUserPrincipalName: DomainUserPrincipalName
    KeyVaultName: KeyVaultName
    LocalAdminPassword: LocalAdminPassword
    LocalAdminUsername: LocalAdminUsername
    Location: Location
    RoleDefinitionId: roleDefinition.id
    SecurityPrincipalObjectIds: SecurityPrincipalObjectIds
  }
}

module templateSpec 'modules/templateSpec.bicep' = {
  scope: rg
  name: 'TemplateSpec_${Timestamp}'
  params: {
    Availability: Availability
    AvailabilitySetNamePrefix: AvailabilitySetNamePrefix
    AvailabilityZones: AvailabilityZones
    DiskEncryptionSetResourceId: DiskEncryptionSetResourceId
    DomainServices: DomainServices
    HostPoolResourceId: HostPoolResourceId
    KeyVaultResourceId: keyVault.outputs.resourceId
    Location: Location
    SessionHostLocation: SessionHostLocation
    SessionHostOuPath: SessionHostOuPath
    SessionHostResourceGroupName: SessionHostResourceGroupName
    SubnetResourceId: SubnetResourceId
    Tags: Tags
    TemplateSpecName: TemplateSpecName
    TemplateSpecVersion: TemplateSpecVersion
  }
}
