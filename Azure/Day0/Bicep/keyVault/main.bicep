@description('Name of the deployment.')
param deploymentName string

@description('object to config azure keyvault')
param keyVault object

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVault.Name
  location: resourceGroup().location
  properties: {
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: [
      for item in keyVault.properties.accessPolicies: {
        // Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. 
        // The object ID must be unique for the list of access policies. 
        // Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.
        objectId: item.objectId
        // Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. 
        // Get it by using Get-AzSubscription cmdlet.
        tenantId: subscription().tenantId
        permissions: {
          // Specifies the permissions to keys in the vault. 
          // Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, 
          // update, import, delete, backup, restore, recover, and purge.
          keys: item.permissions.keys
          // Specifies the permissions to secrets in the vault. 
          // Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.
          secrets: item.permissions.secrets
        }
      }
    ]
    sku: {
      // Specifies whether the key vault is a standard vault or a premium vault.
      name: keyVault.properties.sku.name
      family: 'A'
    }
  }

  resource keys 'keys' = [
    for key in keyVault.keys: {
      name: key.name
      properties: {
        kty: key.properties.kty
        keySize: key.properties.keySize
        keyOps: key.properties.keyOps
        attributes: {
          enabled: key.properties.attributes.enabled
        }
        rotationPolicy: {
          lifetimeActions: [
            for lifetimeAction in key.properties.rotationPolicy.lifetimeActions: {
              action: {
                type: lifetimeAction.action.type
              }
              trigger: {
                timeBeforeExpiry: lifetimeAction.trigger.timeBeforeExpiry
              }
            }
          ]
        }
      }
    }
  ]
}

output deploymentURL string = 'https://portal.azure.com/#@company.com/resource${resourceId('Microsoft.Resources/deployments',deploymentName)}'
output deploymentOverviewURL string = 'https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/${replace(resourceId('Microsoft.Resources/deployments',deploymentName),'/','%2F')}'
output portalUrl string = 'https://portal.azure.com/#@company.com/resource${kv.id}'
