## dev and debug 
### in local (windows)
#### Init (create new) `pyproject.toml` config by poetry
```powershell
# in current dir
$projectName="ADO-Org"
$description="Manage Azure DevOps Organization in this repo via IaC"
$author="WindomWU"
poetry init --name $projectName `
    --description $description `
    --author $author
```
add below config in block `[tool.poetry]` under `pyproject.toml`
```toml
[tool.poetry]
...
package-mode = false
```

#### Activate poetry environment, and add packages in the new project dir  
Usually need to add pulumi related packages
```powershell
poetry use python
poetry add pulumi-azuredevops
```

#### Config poetry venv in vscode  
To make vscode able to detect the virtual environment config by poetry, update `settings.json` in `.vscode\settings.json`
ref: 
- https://github.com/microsoft/vscode/issues/2809
- https://zhuanlan.zhihu.com/p/396566678

```json
"python.venvPath": "%LOCALAPPDATA%\\Local\\pypoetry\\Cache\\virtualenvs",
```
or  
`ctrl + ,` -> `python.analysis.extraPaths` -> set `C:\Users\<username>\AppData\Local\pypoetry\Cache\virtualenvs`

#### Prepare pulumi requirement
Prepare azure storage account as pulumi backend, azure keyvault key as pulumi secret provider
See [../../Day0/Bicep/README.md](../../Day0/Bicep/README.md)

#### Prepare pulumi config
update Pulumi.yaml to
```powershell
$projectName="ADO-Org"
$backendSchema="azblob"
$saContainer="Pulumi-Backend"
$description="Manage Azure DevOps Organization By IaC"
$PulumiYaml=@"
name: $($projectName)
# https://www.pulumi.com/docs/languages-sdks/python/
runtime:
  name: python
  options:
    toolchain: poetry
description: $description
# https://www.pulumi.com/docs/concepts/state/#logging-into-and-out-of-state-backends
backend:
  url: $($backendSchema)://$($saContainer)/$($projectName)
"@
Set-Content -Path "Pulumi.yaml" -Value $PulumiYaml
```

#### Prepare IaC process related permission
1. Login to pulumi backend
```powershell
$keyName="key1", "key2" | Get-Random

$subscription="subscription"
$resourceGroup="resourceGroup"
$env:AZURE_STORAGE_ACCOUNT="AZURE_STORAGE_ACCOUNT"
$env:AZURE_STORAGE_KEY=az storage account keys list `
  --subscription $subscription `
  --resource-group $resourceGroup `
  --account-name $env:AZURE_STORAGE_ACCOUNT `
  --query "[?keyName=='$keyName'].value" `
  --output tsv
pulumi login
```

2. Init pulumi backend stack
Only need to run at the first time
ref:
- https://www.pulumi.com/docs/iac/concepts/secrets/#azure-key-vault
```powershell
# in current dir
$stackName="orgName"
$keyVaultName="keyVaultName"
$keyName="keyName"
$location="location"
$subscriptionId=""
$ADOUrl="https://dev.azure.com/xxxx"
$stacks=@"
[
    {
        "stackName": "$stackName",
        "secretProvider": "azurekeyvault://$keyVaultName.vault.azure.net/keys/$keyName",
        "location": "$location",
        "subscriptionId": "$subscriptionId",
        "ADOUrl": "$ADOUrl"
    },
]
"@ | ConvertFrom-Json
$stacks | Foreach-Object {
  if (-not (Test-Path -Path "Pulumi.$($_.stackName).yaml")) {
    pulumi stack init $($_.stackName) --secrets-provider $($_.secretProvider)
  }
    pulumi config set --stack $($_.stackName) azuredevops:orgServiceUrl $($_.ADOUrl)
}
```

3. Config secret value if needed
```powershell
pulumi config set --secret --path build_defs[0].variables[0].secret_value xxx
```

4. Get and set PAT token 
- prepare PAT token in https://dev.azure.com/company/_usersSettings/tokens, need pipeline, build access right
- config env var for the PAT 
```powershell
$env:AZDO_PERSONAL_ACCESS_TOKEN="xxx<Personal Access Token>"
```

5. Preview / Up the IaC
```powershell
$stackName="default"
pulumi preview --stack $stackName
pulumi up --stack $stackName
```
6. Import some existing resources
```powershell
$stackName="default"
$type="azuredevops:index/buildDefinition:BuildDefinition"
$iacId="320655b8-a305-49c2-a64a-bda42678ec20"
$defProjectName="EOS"
$defId="2650"
pulumi import $type $iacId $defProjectName/$defId --stack $stackName
```

## Run pipeline to apply IaC
- POC-Pulumi-ADO-EXT  : https://dev.azure.com/company/ORG/_build?definitionId=2648
