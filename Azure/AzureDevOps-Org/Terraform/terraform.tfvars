org_service_url = "https://dev.azure.com/company"

git_repos = [{
  name = "POC-Pulumi-ADO-EXT"
  initialization = {
    init_type = "Clean"
  }
}]

build_defs = [{
  name = "POC-Pulumi-ADO-EXT"
  repo = {
    project_name = "ComLab"
    repo_name    = "POC-Pulumi-ADO-EXT"
    branch_name  = "refs/heads/master"
    yml_path     = ".azure-devops/invoke-pulumi.azure-pipeline.yml"
  }
  variable = [{
    name         = "PULUMI_CONFIG_PASSPHRASE"
    is_secret    = true
    secret_value = "P@ssw0rd"
  }]
}]

groups = [
  {
    id           = "ed55819a-f6fd-4681-8965-858c6f5e1ea8" # generate it by command `New-Guid`
    display_name = "IaC-Approver"
    members      = ["windom.wu@mail.sololab"]
  },
]

environments = [
  {
    id                 = "e73c7674-33e7-44f7-8dc6-c6247436da6b" # generate it by command `New-Guid`
    name               = "IaC-approval"
    approver_groups_id = ["ed55819a-f6fd-4681-8965-858c6f5e1ea8"]
  },
]
