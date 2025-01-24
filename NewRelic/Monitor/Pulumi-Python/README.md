## dev and debug 
### in local (windows)
#### Init (create new) `pyproject.toml` config by poetry
```powershell
# in current dir
$projectName="NRMonitor"
$description="Manage NewRelic Monitor via IaC"
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
poetry add pulumi-newrelic
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
See [../../../Azure/Day0/Bicep/README.md](../../../Azure/Day0/Bicep/README.md)

#### Prepare pulumi config
update Pulumi.yaml to
```powershell
$projectName="NRMonitor"
$description="Manage NewRelic Monitor By IaC"
$backendSchema="azblob"
$saContainer="Pulumi-Backend"
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

$subscription="*subscription*"
$resourceGroup="*resourceGroup*"
$env:AZURE_STORAGE_ACCOUNT="*AZURE_STORAGE_ACCOUNT*"
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
$stackName="default"
$keyVaultName="keyVaultName"
$keyName="keyName"
$newRelicAccountId="xxx"
$newRelicApiKey="xxx"
$stacks=@"
[
    {
        "stackName": "$stackName",
        "secretProvider": "azurekeyvault://$keyVaultName.vault.azure.net/keys/$keyName",
        "newRelicAccountId": "$newRelicAccountId",
        "newRelicApiKey": "$newRelicApiKey",
    },
]
"@ | ConvertFrom-Json
$stacks | Foreach-Object {
  if (-not (Test-Path -Path "Pulumi.$($_.stackName).yaml")) {
    pulumi stack init $($_.stackName) --secrets-provider $($_.secretProvider)
  }
    pulumi config set --secret --stack $($_.stackName) --path newrelic:accountId $($_.newRelicAccountId)
    pulumi config set --secret --stack $($_.stackName) --path newrelic:apiKey $($_.newRelicApiKey)
}
```

#### Config variables
Config secret value if needed
```powershell
pulumi config set --secret --path build_defs[0].variables[0].secret_value xxx
```

#### Up and run
1. Preview / Up the IaC
```powershell
$stackName="default"
pulumi preview --stack $stackName
pulumi up --stack $stackName
```
