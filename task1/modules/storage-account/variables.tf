variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "account_tier" {
  type = string
}

variable "account_replication_type" {
  type = string
}

variable "enable_https_traffic_only" {
  type    = bool
  default = true
}

variable "enable_advanced_threat_protection" {
  type    = bool
  default = false
}

variable "file_share_names" {
  description = "The Azure File Shares to create"
  default     = []
}

variable "file_share_quotas" {
  description = "The quota in GB for the file shares."
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}