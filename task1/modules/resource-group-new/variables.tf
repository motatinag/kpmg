variable "resource_group_name" {
    description = "The name of the resource group to create."
    type = string
}

variable "location" {
  description = "The location/region where the core network will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}