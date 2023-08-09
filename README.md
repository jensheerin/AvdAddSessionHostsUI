# Azure Virtual Desktop - Custom Add Session Hosts UI

This solution will deploy a template spec with a custom UI definition to simplify session host deployments for AVD host pools. When a host pool is deployed in the portal, it includes a "VMTemplate" property. This solution makes use of that property to ensure your session hosts are deployed consistently every time.

## Resources

The following resources are deployed with this solution:

- Key Vault
  - Secrets
- Resource Group
- Role Definition
- Template Spec with a custom UI Definition
  - Version

## Prerequisites

To deploy this solution, the following items are required prequisites:

- Permissions: the principal deploying the solution will require the Owner role on the target subscription.
- Outbound network connectivity to download the following resources:
  - Script for Custom Script Extension
  - AVD Agents

> **NOTE:** These assets can be staged in an Azure storage account but you must download and modify the code to support that configuration.

- "vmTemplate" property: If your host pool was created using code or you never created a virtual machine in your host pool, your host pool most likely has a null value for the "vmTemplate" property. This can be easily fixed by manually adding a session host to your host pool in the Azure Portal. Use the following PowerShell command to validate the value of the VMTemplate property on your host pool:

```powershell
Get-AzWvdHostPool `
    -Name '<Host Pool Name>' `
    -ResourceGroupName '<Resource Group Name>' `
    | Select-Object -ExpandProperty 'vmtemplate'
```

## Deployment Options

### Azure Portal

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjensheerin%2FAvdAddSessionHostsUI%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjensheerin%2FAvdAddSessionHostsUI%2Fmain%2FuiDefinition.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjensheerin%2FAvdAddSessionHostsUI%2Fmain%2Fsolution.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fjensheerin%2FAvdAddSessionHostsUI%2Fmain%2FuiDefinition.json)

### PowerShell

````powershell
New-AzDeployment `
    -Location '<Azure location>' `
    -TemplateFile 'https://raw.githubusercontent.com/jensheerin/AvdAddSessionHostsUI/main/solution.json' `
    -Verbose
````

### Azure CLI

````cli
az deployment sub create \
    --location '<Azure location>' \
    --template-uri 'https://raw.githubusercontent.com/jensheerin/AvdAddSessionHostsUI/main/solution.json'
````  
