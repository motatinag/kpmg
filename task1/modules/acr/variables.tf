variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "ext_service_principal_id" {
  type    = string
  default = ""
}

variable "admin_user_enabled" {
  type        = bool
  description = "True to enable an admin user, otherwise False."
  default     = false
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}