@secure()
param DomainPassword string
@secure()
param DomainUserPrincipalName string
param KeyVaultName string
param Location string
param RoleDefinitionId string
@secure()
param LocalAdminPassword string
@secure()
param LocalAdminUsername string
param SecurityPrincipalObjectIds array

var Secrets = [
  {
    // Key Vault secret for the domain join password to add AVD session hosts to the domain
    name: 'DomainPassword'
    value: DomainPassword
  }
  {
    // Key Vault secret for the domain join username to add AVD session hosts to the domain
    name: 'DomainUserPrincipalName'
    value: DomainUserPrincipalName
  }
  {
    // Key Vault Secret for the local admin password on the virtual machine
    name: 'LocalAdminPassword'
    value: LocalAdminPassword
  }
  {
    // Key Vault Secret for the local admin username on the virtual machine
    name: 'LocalAdminUsername'
    value: LocalAdminUsername
  }
]

// The Key Vault stores the secrets to deploy virtual machine and mount the SMB share(s)
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: KeyVaultName
  location: Location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    enableSoftDelete: false
    publicNetworkAccess: 'Enabled'
  }
}

resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = [for Secret in Secrets: {
  parent: keyVault
  name: Secret.name
  properties: {
    value: Secret.value
  }
}]

// Gives the selected users rights to get key vault secrets in deployments
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for i in range(0, length(SecurityPrincipalObjectIds)): if(!empty(SecurityPrincipalObjectIds)) {
  name: guid(SecurityPrincipalObjectIds[i], RoleDefinitionId, resourceGroup().id)
  scope: keyVault
  properties: {
    roleDefinitionId: RoleDefinitionId
    principalId: SecurityPrincipalObjectIds[i]
  }
}]

output resourceId string = keyVault.id
