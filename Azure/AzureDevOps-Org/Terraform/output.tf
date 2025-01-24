output "git_repos_url" {
  value = tomap({
    for key, value in azuredevops_git_repository.repos :
    key => value.web_url
  })
}

output "build_defs_url" {
  value = tomap({
    for key, value in azuredevops_build_definition.build_defs :
    key => "${var.org_service_url}/${data.azuredevops_project.project.name}/_build?definitionId=${value.id}"
  })
}

output "permission_groups" {
  value = [
    for value in azuredevops_group.groups : {
      "${value.display_name}" = "${var.org_service_url}/${data.azuredevops_project.project.name}/_settings/permissions?subjectDescriptor=${value.descriptor}"
    }
  ]
}
