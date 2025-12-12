### Install GCP SDK
```powershell
winget install Google.CloudSDK
```

### Login to GCP
```powershell
$proxy="http://127.0.0.1:7890"
$env:http_proxy=$proxy
$env:https_proxy=$proxy
gcloud auth login
```
### Create a new project
```powershell
$orgID="xxx"
$projectID="xxx"
$folderID="xxx"
gcloud projects create $projectID `
    --organization $orgID `
    --folder $folderID `
    --enable-cloud-apis
```


### Enable GCP Infrastructure Manager API
ref: https://docs.cloud.google.com/infrastructure-manager/docs/enable-service

1. Verify that billing is enabled for your Google Cloud project.
```powershell
$projectID="xxx"
gcloud billing projects describe $projectID
```

2. Enable GCP Config API
```powershell
gcloud services enable config.googleapis.com --project $projectID
```

3. enable the API from Google Cloud console or with the following gcloud command:
```powershell
gcloud services enable cloudquotas.googleapis.com --project $projectID
```

4. Set up IAM for infrastructure manager
```powershell
$serviceAccountName="sa-infra-manager"
gcloud iam service-accounts create $serviceAccountName --project $projectID
```

5. Grant the roles/config.agent IAM role to the service account
```powershell
gcloud projects add-iam-policy-binding $projectID `
    --member="serviceAccount:$serviceAccountName@$projectID.iam.gserviceaccount.com" `
    --role=roles/config.agent
```

6. Grant some IAM roles to the service account
```powershell
$roles=@(
    # https://github.com/terraform-google-modules/terraform-google-network?tab=readme-ov-file#configure-a-service-account
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
gcloud infra-manager previews create projects/$projectID/locations/us-central1/previews/quickstart-preview `
    --service-account projects/$projectID/serviceAccounts/$serviceAccountName@$projectID.iam.gserviceaccount.com `
    --git-source-repo=https://github.com/fsdrw08/CloudLab `
    --git-source-directory=GCP/simple_autopilot_public `
    --git-source-ref=v42.0.0 `
    --input-values=project_id=$projectID,region=$region,base_name=$base_name
```
