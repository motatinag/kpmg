variable "name" {
  type        = string
  description = "(Required) Specifies the name of the Log Analytics Workspace. Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol. Changing this forces a new resource to be created"
}

variable "resource_group_name" {
  type        = string
  description = "The name of an existing resource group for the Key Vault."
}

variable "offer_type" {
  type        = string
  description = "(Required) Specifies the Offer Type to use for this CosmosDB Account - currently this can only be set to Standard."
  default     = "Standard"
}

variable "kind" {
  type        = string
  description = "(Optional) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created."
  default     = "GlobalDocumentDB"
}

variable "enable_multiple_write_locations" {
  type        = bool
  description = "(Optional) Enable multi-master support for this Cosmos DB account."
  default     = true
}

variable "enable_automatic_failover" {
  type        = bool
  description = "(Optional) Enable automatic fail over for this Cosmos DB account."
  default     = true
}

variable "is_virtual_network_filter_enabled" {
  type        = bool
  description = "(Optional) Enables virtual network filtering for this Cosmos DB account."
  default     = false  
}

variable "ip_range_filter" {
  type        = string
  description = "(Optional) Specifies the Kind of CosmosDB to create - possible values are GlobalDocumentDB and MongoDB. Defaults to GlobalDocumentDB. Changing this forces a new resource to be created."
  #default     = "198.203.181.181,198.203.175.175,198.203.177.177,149.111.28.128,149.111.30.128"  
  default     = ""
}

variable "vnet_subnet_id" {
  type        = string
  description = "The ID of the virtual network subnet."
  default     = ""
}

variable "consistency_level" {
  type        = string
  description = "(Required) The Consistency Level to use for this CosmosDB Account - can be either BoundedStaleness, Eventual, Session, Strong or ConsistentPrefix."
}

variable "max_interval_in_seconds" {
  type        = number
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 5 - 86400 (1 day). Defaults to 5. Required when consistency_level is set to BoundedStaleness."
  default     = 5
}

variable "max_staleness_prefix" {
  type        = number
  description = "(Optional) When used with the Bounded Staleness consistency level, this value represents the number of stale requests tolerated. Accepted range for this value is 10 – 2147483647. Defaults to 100. Required when consistency_level is set to BoundedStaleness."
  default     = 100  
}

#TODO - Enhance to support multiple Geo Location blocks
variable "geo_location" {
  type        = string
  description = "(Required) The name of the Azure region to host replicated data."
}

variable "failover_priority" {
  type        = number
  description = "(Required) The failover priority of the region."
  default     = 0  
}


variable "tags" {
  type        = map
  description = "A mapping of tags to assign to the resources."
  default     = {}
}


