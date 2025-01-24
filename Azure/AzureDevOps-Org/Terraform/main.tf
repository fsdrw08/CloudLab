data "azuredevops_project" "project" {
  name = "ComLab"
}

resource "azuredevops_git_repository" "repos" {
  for_each = {
    for git_repo in var.git_repos : git_repo.name => git_repo
  }
  project_id = data.azuredevops_project.project.id
  name       = each.value.name
  initialization {
    init_type             = each.value.initialization.init_type
    source_type           = each.value.initialization.source_type
    source_url            = each.value.initialization.source_url
    service_connection_id = each.value.initialization.service_connection_id
  }
}
data "azuredevops_project" "build_defs_project" {
  for_each = {
    for build_def in var.build_defs : build_def.name => build_def
  }
  name = each.value.repo.project_name
}

data "azuredevops_git_repository" "build_defs_repo" {
  for_each = {
    for build_def in var.build_defs : build_def.name => build_def
  }
  project_id = data.azuredevops_project.build_defs_project[each.key].id
  name       = each.value.repo.repo_name
}

resource "azuredevops_build_definition" "build_defs" {
  for_each = {
    for build_def in var.build_defs : build_def.name => build_def
  }
  project_id = data.azuredevops_project.project.id
  name       = each.value.name

  ci_trigger {
    use_yaml = true
  }
  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.build_defs_repo[each.value.repo.repo_name].id
    branch_name = each.value.repo.branch_name
    yml_path    = each.value.repo.yml_path
  }

  dynamic "variable" {
    for_each = each.value.variable == null ? [] : flatten([each.value.variable])
    content {
      name           = variable.value.name
      value          = variable.value.value
      is_secret      = variable.value.is_secret
      secret_value   = variable.value.secret_value
      allow_override = variable.value.allow_override
    }
  }
}


# put all members in groups.members in to one data set
data "azuredevops_users" "groups_members" {
  for_each = {
    for member in setunion(
      flatten([
        for group in var.groups : group.members
    ])) : member => member
  }
  principal_name = each.key
}

resource "azuredevops_group" "groups" {
  for_each = {
    for group in var.groups : group.id => group
  }
  scope        = data.azuredevops_project.project.id
  display_name = each.value.display_name
  description  = each.value.description
  members = [
    for member in each.value.members : one(data.azuredevops_users.groups_members[member].users).descriptor
  ]
}

# https://programmingwithwolfgang.com/deployment-approvals-yaml-pipeline
resource "azuredevops_environment" "environments" {
  for_each = {
    for environment in var.environments : environment.id => environment
  }
  project_id  = data.azuredevops_project.project.id
  name        = each.value.name
  description = each.value.description
}

resource "azuredevops_check_approval" "environment_approvals" {
  for_each = {
    for environment in var.environments : environment.id => environment
  }
  project_id           = data.azuredevops_project.project.id
  target_resource_type = "environment"
  target_resource_id   = azuredevops_environment.environments[each.key].id

  requester_can_approve = true
  approvers = [
    for approver_group_id in each.value.approver_groups_id : azuredevops_group.groups[approver_group_id].origin_id
  ]
}
