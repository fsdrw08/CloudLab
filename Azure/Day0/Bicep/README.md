## create IaC related infra for xxx project
Create resource group in subscriptions: 
- [Subscription](https://portal.azure.com/), 

then create keyvault and storage account under this resource group  

## resource name
resource group name: `xxxx`  
storage account name: `xxx`  
key vault name: `xxx`  

## why bicep
As a day0 project to provision IaC's related dependency infrastructure(e.g. storage account for IaC backend, key in keyvault for IaC backend encryption), seems that we cannot use other IaC tools for that, as we don't have any backend at the beginning (terraform/pulumi require a backend to storage infra's state). I try to use ARM template first, as ARM template doesn't require a backend to storage cloud resource's state, and I found that bicep can generate ARM template, so, why not use bicep directly?

## deploy process
1. create resource group  

ref: 
- [Microsoft.Resources resourceGroups](https://learn.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups?pivots=deployment-language-arm-template)
- [Subscription deployments with ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-subscription?tabs=azure-cli)
- [azure-quickstart-templates/subscription-deployments/create-rg/](https://github.com/Azure/azure-quickstart-templates/tree/master/subscription-deployments/create-rg)
- [How to deploy resources with Bicep and Azure CLI - Deployment scope](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli#deployment-scope)

PIM up if required: 

```powershell
# default env
$templateFile=".\resourceGroups\main.bicep"
$paramsFile=".\resourceGroups\main.default.parameters.jsonc"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.deploymentName.metadata.subscriptionId
$location=$parameters.deploymentName.metadata.location

az deployment sub what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --location $location

az deployment sub create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --location $location

# other env
$paramsFile=".\resourceGroups\main.other.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.subscriptionId.value
$location=$parameters.resourceGroupLocation.value

az deployment sub what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --location $location

az deployment sub create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --location $location
```

2. create storage account  

ref:
- [Microsoft.Storage storageAccounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)
- [quickstarts/microsoft.storage/storage-account-create](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.storage/storage-account-create)


```powershell
# default
$templateFile=".\storageAccounts\main.bicep"
$paramsFile=".\storageAccounts\main.default.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.deploymentName.metadata.subscriptionId
$resourceGroupName=$parameters.deploymentName.metadata.resourceGroupName

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

# other 
$templateFile=".\storageAccounts\main.bicep"
$paramsFile=".\storageAccounts\main.other.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.subscriptionId.value
$resourceGroupName=$parameters.resourceGroupName.value

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName
```

3. create key vault  

ref:
- [Microsoft.KeyVault vaults](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep)
- [quickstarts/microsoft.keyvault/key-vault-create](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.keyvault/key-vault-create/main.bicep)

```bash
# bash default
templateFile="./keyVault/main.bicep"
paramsFile="./keyVault/main.default.parameters.json"
deploymentName=$(grep -v '//' $paramsFile | jq -r '.parameters.deploymentName.value' )
subscriptionId=$(grep -v '//' $paramsFile | jq -r '.parameters.deploymentName.metadata.subscriptionId')
resourceGroupName=$(grep -v '//' $paramsFile | jq -r '.parameters.deploymentName.metadata.resourceGroupName')
az deployment group what-if \
    --template-file $templateFile \
    --parameters $paramsFile \
    --name $deploymentName \
    --subscription $subscriptionId \
    --resource-group $resourceGroupName
    
az deployment group create \
    --template-file $templateFile \
    --parameters $paramsFile \
    --name $deploymentName \
    --subscription $subscriptionId \
    --resource-group $resourceGroupName
```

```powershell
# posh default
$templateFile=".\keyVault\main.bicep"
$paramsFile=".\keyVault\main.default.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.deploymentName.metadata.subscriptionId
$resourceGroupName=$parameters.deploymentName.metadata.resourceGroupName

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

# other 
$templateFile=".\storageAccounts\main.bicep"
$paramsFile=".\storageAccounts\main.other.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.subscriptionId.value
$resourceGroupName=$parameters.resourceGroupName.value

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName
```

4. Create compute gallery (aka image gallery)

```powershell
# non-other
$templateFile=".\computeGallery\main.bicep"
$paramsFile=".\computeGallery\main.default.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.deploymentName.metadata.subscriptionId
$resourceGroupName=$parameters.deploymentName.metadata.resourceGroupName

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

# other 
$templateFile=".\computeGallery\main.bicep"
$paramsFile=".\computeGallery\main.other.parameters.json"
$parameters=(Get-Content -path $paramsFile | ConvertFrom-Json).parameters
$deploymentName=$parameters.deploymentName.value
$subscriptionId=$parameters.subscriptionId.value
$resourceGroupName=$parameters.resourceGroupName.value

az deployment group what-if `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName

az deployment group create `
    --template-file $templateFile `
    --parameters $paramsFile `
    --name $deploymentName `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName
```
