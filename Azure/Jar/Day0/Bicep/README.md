### Install az cli
```powershell
winget install Microsoft.AzureCLI
```

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
0. Login to Azure
```powershell
az login
```
1. [create resource group](./resourceGroups)  

ref: 
- [Microsoft.Resources resourceGroups](https://learn.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups?pivots=deployment-language-arm-template)
- [Subscription deployments with ARM templates](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-to-subscription?tabs=azure-cli)
- [azure-quickstart-templates/subscription-deployments/create-rg/](https://github.com/Azure/azure-quickstart-templates/tree/master/subscription-deployments/create-rg)
- [How to deploy resources with Bicep and Azure CLI - Deployment scope](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli#deployment-scope)

PIM up if required: 

```powershell
# default env
$repoDir=git rev-parse --show-toplevel
$childPath="Azure/Jar/Day0/Bicep/resourceGroups/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

$templateFile="main.bicep"
$paramsFile="main.parameters.jsonc"
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

2. [create storage account](./storageAccounts/)  

ref:
- [Microsoft.Storage storageAccounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)
- [quickstarts/microsoft.storage/storage-account-create](https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.storage/storage-account-create)


```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="Azure/Jar/Day0/Bicep/storageAccounts/"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)
# default
$templateFile="main.bicep"
$paramsFile="main.parameters.jsonc"
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
