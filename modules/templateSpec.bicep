param Availability string
param AvailabilitySetNamePrefix string
param AvailabilityZones array
param DiskEncryptionSetResourceId string
param DomainServices string
param HostPoolResourceId string
param KeyVaultResourceId string
param Location string
param SessionHostLocation string
param SessionHostOuPath string
param SessionHostResourceGroupName string
param SubnetResourceId string
param Tags object
param TemplateSpecName string
param TemplateSpecVersion string

var HostPoolName = split(HostPoolResourceId, '/')[8]
var TemplateSpecString = string(loadJsonContent('../artifacts/templateSpec.json'))
var TemplateSpecAvailability = replace(TemplateSpecString, 'AvailabilityDefaultValue', Availability)
var TemplateSpecAvailabilitySetNamePrefix = replace(TemplateSpecAvailability, 'AvailabilitySetNamePrefixDefaultValue', AvailabilitySetNamePrefix)
var TemplateSpecAvailabilityZones = replace(TemplateSpecAvailabilitySetNamePrefix, '["1"]', string(AvailabilityZones))
var TemplateSpecDiskEncryptionSetResourceId = replace(TemplateSpecAvailabilityZones, 'DiskEncryptionSetResourceIdDefaultValue', DiskEncryptionSetResourceId)
var TemplateSpecDomainServices = replace(TemplateSpecDiskEncryptionSetResourceId, 'DomainServicesDefaultValue', DomainServices)
var TemplateSpecHostPoolResourceId = replace(TemplateSpecDomainServices, 'HostPoolResourceIdDefaultValue', HostPoolResourceId)
var TemplateSpecKeyVaultResourceId = replace(TemplateSpecHostPoolResourceId, 'KeyVaultResourceIdDefaultValue', KeyVaultResourceId)
var TemplateSpecSessionHostLocation = replace(TemplateSpecKeyVaultResourceId, 'SessionHostLocationDefaultValue', SessionHostLocation)
var TemplateSpecSessionHostOuPath = replace(TemplateSpecSessionHostLocation, 'SessionHostOuPathDefaultValue', SessionHostOuPath)
var TemplateSpecSessionHostResourceGroupName = replace(TemplateSpecSessionHostOuPath, 'SessionHostResourceGroupNameDefaultValue', SessionHostResourceGroupName)
var TemplateSpecJson = replace(TemplateSpecSessionHostResourceGroupName, 'SubnetResourceIdDefaultValue', SubnetResourceId)
var UiDefinitionString = string(loadJsonContent('../artifacts/uiDefinition.json'))
var UiDefinitionTitle = replace(UiDefinitionString, 'TitleDefaultValue', 'Add Session Hosts to ${HostPoolName}')
var UiDefinitionSessionHostLocation = replace(UiDefinitionTitle, 'SessionHostLocationDefaultValue', SessionHostLocation)
var UiDefinitionJson = replace(UiDefinitionSessionHostLocation, 'SubscriptionNameDefaultValue', subscription().displayName)

resource templateSpec 'Microsoft.Resources/templateSpecs@2022-02-01' = {
  name: TemplateSpecName
  location: Location
  tags: Tags
}

resource version 'Microsoft.Resources/templateSpecs/versions@2022-02-01' = {
  parent: templateSpec
  name: TemplateSpecVersion
  location: Location
  tags: Tags
  properties: {
    mainTemplate: json(TemplateSpecJson)
    uiFormDefinition: json(UiDefinitionJson)
  }
}
