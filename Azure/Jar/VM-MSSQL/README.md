### Login to Azure
ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
```powershell
az login
```

### run terraform
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="Azure/Jar/VM-MSSQL"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

sudo pwsh.exe -c "terraform init";
$subscriptionName=Read-Host " Please input your subscription name: <band><region>-shared-001"
$env:ARM_SUBSCRIPTION_ID = (az account subscription list --only-show-errors --query "[?displayName=='$subscriptionName'].id" | ConvertFrom-Json | Select-Object -first 1) -split "/" | Select-Object -last 1
terraform plan
terraform apply
```

### Troubleshooting
ref: https://github.com/hashicorp/terraform/issues/17046
for below scenario
```log
Acquiring state lock. This may take a few moments...
╷
│ Error: Error acquiring the state lock
│
│ Error message: state blob is already locked
│ blob metadata "terraformlockid" was empty
│
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
```
run below command to check the lock status
```powershell
az storage blob show --container-name <container-name> --name <blob-name> `
--account-name <storage-account-name> --account-key <access-key> `
--subscription <subscription-name>
```