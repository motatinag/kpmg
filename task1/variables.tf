# ---------------------------------------------------------------------------------------------------------------------
# Input variable definitions
# ---------------------------------------------------------------------------------------------------------------------

# The Azure region
variable "location" {
  type = string
}

# Short form of Azure region, used for naming resources
variable "location_short" {
  type = string
}

# The environment name, used for tagging resources
variable "environment_desc" {
  type = string
}

# Short form of environment, used for naming resources
variable "environment" {
  type = string
}

# Application or componentname, used for naming resources
variable "platform_name" {
  type = string
}

# The address space for the main vnet
variable "address_space" {
  type = string
}

# The second octet of the ip address 172.x.0.0
variable "network_id" {
  type = string
}

variable "app_service_tier" {

  type = string
}

variable "app_service_size" {
  
}

variable "api_management_publisher_name" {
  type = string
}

variable "api_management_publisher_email" {
  
}
variable "api_management_notification_sender_email" {
    default = "apimgmt-noreply@mail.windowsazure.com"
  
}

variable "api_management_sku_name" {
  
}

variable "poc_aks_dns_prefix" {
  
}
variable "poc_aks_k8s_version" {
  
}
variable "poc_aks_node_resource_group_name" {
  
}
variable "poc_aks_agent_pool_name" {
  
}

variable "poc_aks_agent_pool_node_count" {
  
}

variable "poc_aks_agent_pool_node_min_count" {
  
}
variable "poc_aks_agent_pool_node_max_count" {
  
}
variable "poc_aks_agent_pool_vm_size" {
  
}

variable "poc_aks_agent_pool_os_disk_size_gb" {
  
}
variable "client_id" {
  
}

variable "client_secret" {
  
}
variable "waf_policy_name" {
  
}
