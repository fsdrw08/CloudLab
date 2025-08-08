@description('Name of the deployment.')
param deploymentName string

@description('object to config storage account')
param storageAccount object

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccount.name
  location: resourceGroup().location
  sku: {
    name: storageAccount.skuName
  }
  kind: 'StorageV2'
  properties: {}

  resource blobServices 'blobServices' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        allowPermanentDelete: false
        enabled: false
      }
    }

    resource container 'containers' = [
      for item in storageAccount.containers: {
        name: '${item}-${uniqueString(item)}'
      }
    ]
  }
}

output deploymentURL string = 'https://portal.azure.com/#@company.com/resource${resourceId('Microsoft.Resources/deployments',deploymentName)}'
output deploymentOverviewURL string = 'https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/${replace(resourceId('Microsoft.Resources/deployments',deploymentName),'/','%2F')}'
output portalUrl string = 'https://portal.azure.com/#@company.com/resource${sa.id}'
