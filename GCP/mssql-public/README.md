### Login GCP with application default credentials
ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#running-terraform-on-your-workstation
```powershell
$proxy="http://127.0.0.1:7890"
$env:HTTP_PROXY=$proxy;$env:HTTPS_PROXY=$proxy;$env:NO_PROXY="localhost,127.0.0.1"
gcloud auth application-default login
```

### run terraform
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="GCP/mssql-public"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

sudo terraform init
terraform plan
terraform apply
```