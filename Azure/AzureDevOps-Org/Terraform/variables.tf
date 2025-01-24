variable "org_service_url" {
  type = string
}

variable "git_repos" {
  type = list(object({
    name                 = string
    parent_repository_id = optional(string, null)
    initialization = object({
      init_type             = string
      source_type           = optional(string, null)
      source_url            = optional(string, null)
      service_connection_id = optional(string, null)
    })
  }))
}

variable "build_defs" {
  type = list(object({
    name = string
    repo = object({
      project_name = string
      repo_name    = string
      branch_name  = string
      yml_path     = string
    })
    variable = optional(list(object({
      name           = string
      value          = optional(string, null)
      is_secret      = optional(bool, null)
      secret_value   = optional(string, null)
      allow_override = optional(string, null)
    })))
  }))
}

variable "groups" {
  type = list(object({
    id           = string
    display_name = string
    members      = list(string)
    description  = optional(string, null)
  }))
}

variable "environments" {
  type = list(object({
    id                 = string
    name               = string
    description        = optional(string, null)
    approver_groups_id = optional(list(string), null)
  }))
}

