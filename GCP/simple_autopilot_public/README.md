### Grant some IAM roles to the service account
```powershell
$roles=@(
    # https://github.com/terraform-google-modules/terraform-google-network?tab=readme-ov-file#configure-a-service-account
    # https://github.com/terraform-google-modules/terraform-google-kubernetes-engine?tab=readme-ov-file#configure-a-service-account
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/compute.storageAdmin",
    "roles/compute.viewer",
    "roles/container.admin",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/resourcemanager.projectIamAdmin"
)
foreach ($role in $roles) {
    gcloud projects add-iam-policy-binding $projectID `
        --member="serviceAccount:$serviceAccountName@$projectID.iam.gserviceaccount.com" `
        --role=$role
}
```

### Create a preview of the deploy
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="GCP/simple_autopilot_public"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

$serviceAccountName="sa-infra-manager"
$projectID="xxx"
$region="asia-east1"
gcloud infra-manager previews create projects/$projectID/locations/$region/previews/quickstart-preview `
    --service-account projects/$projectID/serviceAccounts/$serviceAccountName@$($projectID).iam.gserviceaccount.com `
    --git-source-repo=https://github.com/fsdrw08/CloudLab `
    --git-source-directory=GCP/simple_autopilot_public `
    --git-source-ref=main `
    --inputs-file=terraform.tfvars
```

### Create a deploy of the preview
```powershell
$repoDir=git rev-parse --show-toplevel
$childPath="GCP/simple_autopilot_public"
Set-Location -Path (Join-Path -Path $repoDir -ChildPath $childPath)

$projectID="xxx"
$region="asia-east1"
$serviceAccountName="sa-infra-manager"

gcloud infra-manager deployments apply projects/$projectID/locations/$region/deployments/quickstart-deployment `
    --project=$projectID `
    --service-account=projects/$projectID/serviceAccounts/$serviceAccountName@$($projectID).iam.gserviceaccount.com `
    --git-source-repo=https://github.com/fsdrw08/CloudLab `
    --git-source-directory=GCP/simple_autopilot_public `
    --git-source-ref=main `
    --inputs-file=terraform.tfvars
```

### To delete the deploy of the preview
```powershell
$projectID="xxx"
$region="asia-east1"
gcloud infra-manager deployments delete projects/$projectID/locations/$region/deployments/quickstart-deployment `
    --project=$projectID
```

### Get GKE cluster credentials
```powershell
$projectID="xxx"
$baseName="xxx"
$region="asia-east1"
$clusterName="$baseName-autopilot-public"
gcloud container clusters get-credentials $clusterName --location=$region --project=$projectID
```