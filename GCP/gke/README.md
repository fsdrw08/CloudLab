### Enable GCP compute API
ref: https://github.com/terraform-google-modules/terraform-google-memorystore/tree/main?tab=readme-ov-file#enable-apis
```powershell
$proxy="http://127.0.0.1:7890"
$env:HTTP_PROXY=$proxy;$env:HTTPS_PROXY=$proxy;$env:NO_PROXY="localhost,127.0.0.1"
$projectId=Read-Host -Prompt "Enter project id"
gcloud services enable container.googleapis.com --project $projectId
```

### Login GCP with application default credentials
ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#running-terraform-on-your-workstation
```powershell
gcloud auth application-default login
```

### run terraform
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="GCP/gke"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

sudo pwsh.exe -c "[System.Environment]::SetEnvironmentVariable('HTTPS_PROXY',`"$env:HTTPS_PROXY`"); terraform init";
terraform plan
terraform apply
```