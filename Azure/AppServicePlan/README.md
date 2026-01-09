### Login to Azure
ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
```powershell
az login
```

### run terraform
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="Azure/AppServicePlan"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

sudo pwsh.exe -c "terraform init";
terraform plan
terraform apply
```