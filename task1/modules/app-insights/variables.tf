variable "name" {
  description = "Name of the Application Insights resource."
}
variable "resource_group_name" {
  description = "Name of resource group to deploy Application Insights into."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}