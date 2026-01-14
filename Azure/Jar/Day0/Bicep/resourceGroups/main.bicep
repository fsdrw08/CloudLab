targetScope = 'subscription'

@description('Name of the deployment.')
param companyName string

@description('Object of the deployment.')
param deploymentName string

@description('Name of the resource group to create.')
param resourceGroups array

// @description('Name of the resource group to create.')
// param resourceGroupName string

// @description('Azure Region the resource group will be created in.')
// param resourceGroupLocation string = az.deployment().location

// resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
//   name: resourceGroupName
//   location: resourceGroupLocation
// }

resource rgs 'Microsoft.Resources/resourceGroups@2022-09-01' = [
  for resourceGroup in resourceGroups: {
    name: resourceGroup.name
    location: resourceGroup.location
  }
]

output deploymentURL string = 'https://portal.azure.com/#@${companyName}/resource${resourceId('Microsoft.Resources/deployments',deploymentName)}'
output deploymentOverviewURL string = 'https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/${replace(resourceId('Microsoft.Resources/deployments',deploymentName),'/','%2F')}'
// output portalUrl string = 'https://portal.azure.com/#@${companyName}/resource${rg.id}'
output portalUrls array = [
  for i in range(0, length(resourceGroups)): {
    name: rgs[i].name
    portalUrl: 'https://portal.azure.com/#@${companyName}/resource${rgs[i].id}'
  }
]
