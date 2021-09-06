variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "ns_rules" {
  type    = "list"
  default = []
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}