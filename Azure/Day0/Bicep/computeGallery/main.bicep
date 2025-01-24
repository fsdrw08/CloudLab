@description('Name of the deployment.')
param deploymentName string

@description('object to config azure keyvault')
param gallery object

// https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/galleries?pivots=deployment-language-bicep
resource sig 'Microsoft.Compute/galleries@2023-07-03' = {
  name: gallery.name
  location: gallery.location
  properties: {
    identifier: {}
    // softDeletePolicy: {
    //   isSoftDeleteEnabled: gallery.properties.softDeletePolicy.isSoftDeleteEnabled
    // }
  }

  resource imgDef 'images@2023-07-03' = {
    name: gallery.imageDefinition.name
    location: gallery.location
    properties: {
      architecture: gallery.imageDefinition.properties.architecture
      identifier: {
        offer: gallery.imageDefinition.properties.identifier.offer
        publisher: gallery.imageDefinition.properties.identifier.publisher
        sku: gallery.imageDefinition.properties.identifier.sku
      }
      osType: gallery.imageDefinition.properties.osType
      osState: gallery.imageDefinition.properties.osState
    }
  }
}

output deploymentURL string = 'https://portal.azure.com/#@company.com/resource${resourceId('Microsoft.Resources/deployments',deploymentName)}'
output deploymentOverviewURL string = 'https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/${replace(resourceId('Microsoft.Resources/deployments',deploymentName),'/','%2F')}'
output sigPortalUrl string = 'https://portal.azure.com/#@company.com/resource${sig.id}'
output imgDefPortalUrl string = 'https://portal.azure.com/#@company.com/resource${sig::imgDef.id}'
