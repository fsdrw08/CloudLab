### Login to Azure
ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
```powershell
az login
```

### run terraform
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="Azure/Jar/VNet"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

sudo pwsh.exe -c "terraform init";
$subscriptionName=Read-Host " Please input your subscription name: <band><region>-shared-001"
$env:ARM_SUBSCRIPTION_ID = (az account subscription list --only-show-errors --query "[?displayName=='$subscriptionName'].id" | ConvertFrom-Json | Select-Object -first 1) -split "/" | Select-Object -last 1
terraform plan
terraform apply
```