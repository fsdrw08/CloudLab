### Grant some IAM roles to the service account
```powershell
$projectID="xxx"
$serviceAccountName="sa-infra-manager"
$roles=@(
    # https://github.com/terraform-google-modules/terraform-google-sql-db?tab=readme-ov-file#configure-a-service-account
    "roles/cloudsql.admin",
    "roles/compute.networkAdmin"
)
foreach ($role in $roles) {
    gcloud projects add-iam-policy-binding $projectID `
        --member="serviceAccount:$serviceAccountName@$projectID.iam.gserviceaccount.com" `
        --role=$role
}
```

### Enable APIs
```powershell
$apis=@(
    "sqladmin.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudresourcemanager.googleapis.com"
)
foreach ($api in $apis) {
    gcloud services enable $api --project $projectID
}
```

### Create a preview of the deploy
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="GCP/mssql-public"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

$serviceAccountName="sa-infra-manager"
$projectID="xxx"
$region="asia-east1"
gcloud infra-manager previews create projects/$projectID/locations/$region/previews/quickstart-preview `
    --service-account projects/$projectID/serviceAccounts/$serviceAccountName@$($projectID).iam.gserviceaccount.com `
    --git-source-repo=https://github.com/fsdrw08/CloudLab `
    --git-source-directory=$($childPath) `
    --git-source-ref=main `
    --inputs-file=terraform.tfvars
```