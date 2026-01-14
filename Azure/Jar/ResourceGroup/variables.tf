variable "resource_groups" {
  type = list(object({
    name     = string
    location = string
  }))
}
