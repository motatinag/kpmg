variable "virtual_network_name" {
  type = string
}

variable "resource_group_name" {
  description = "Resource group that the network will be created in."
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

# If no values specified, this defaults to Azure DNS 
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["subnet1"]
}

variable "subnet_service_endpoints" {
  description = "A list of services to expose on the subnet."
  default     = []
}

variable "ddos_plan_name" {
  description = "Name of the DDoS protection plan."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags"
}