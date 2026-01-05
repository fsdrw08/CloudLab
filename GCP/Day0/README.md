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

```powershell
gcloud services enable cloudresourcemanager.googleapis.com --project $projectID
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

6. Create tf backend bucket by gcloud infra-manager  
see [simple_bucket/README.md](./simple_bucket/README.md)