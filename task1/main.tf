# Local Variables
locals {
 # Naming prefix for resources using platform, environment, and location
  resource_prefix = "${var.platform_name}-${var.environment}-${var.location_short}"

  tags = {
    Environment = var.environment_desc
    Project     = "poc"
    Terraform   = true
    
    
  }
}
# Resource Group
# Create new resource group
module "main_resource_group" {
  source              = ".//modules/resource-group-new"
  resource_group_name = "${local.resource_prefix}-rg"
  location            = var.location
  tags                = local.tags
}

# Azure Container Registry
module "acr" {
  source              = ".//modules/acr"
  name                = "${local.resource_prefix}-acr"
  sku                 = var.acr_sku
  location            = var.location
  resource_group_name = module.main_resource_group.resource_group_name
  tags                = local.tags

  admin_user_enabled  = true
}

# Application Insights 
module "app_insights" {
  source              = ".//modules/app-insights"
  name                = "${local.resource_prefix}-appinsights"
  resource_group_name = module.main_resource_group.resource_group_name
  tags                = local.tags
}
data "azurerm_client_config" "current" {}
 
 
 
#TODO - ADD APP INSIGHTS, monitoring log analytics workspace
module log_analytics_workspace {
  source              = ".//modules/log_analytics_workspace"

  name                = "${local.resource_prefix}-law"
  location            = module.main_resource_group.location
  resource_group_name = module.main_resource_group.resource_group_name
  tags                = local.tags

}

data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "kv" {
  name                        = "${local.resource_prefix}-key"
  location            = var.location
  resource_group_name         = module.main_resource_group.resource_group_name
  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  tags                = local.tags


  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["get", "list", "set", "delete", "recover", "backup", "restore"]
    key_permissions = ["Get","List","Update","Create","Import","Delete","Recover","Backup","Restore"]
    certificate_permissions = ["Get","List","Update","Create","Import","Delete","Recover","Backup","Restore","ManageContacts","ManageIssuers","GetIssuers","ListIssuers","SetIssuers","DeleteIssuers"]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

}

# Random Id Generator
resource "random_id" "rule1" {
  byte_length = 8
}

resource "random_id" "rule2" {
  byte_length = 8
}

resource "random_id" "rule3" {
  byte_length = 8
}

resource "random_id" "rule4" {
  byte_length = 8
}

# Virtual Network with DDOS-plan and 8 subnets
module "main_vnet" {
  source               = ".//modules/network"
  location             = var.location
  virtual_network_name = "${local.resource_prefix}-vnet"
  resource_group_name  = module.main_resource_group.resource_group_name
  address_space        = [var.address_space]
  dns_servers          = null
  subnet_prefixes = ["172.${var.network_id}.1.0/24",
    "172.${var.network_id}.4.0/22",
    "172.${var.network_id}.2.0/24"
   

  ]
  subnet_names = ["${var.platform_name}-agw-subnet",
    "${var.platform_name}-aks-subnet",
    "${var.platform_name}-apim-subnet"

  ]
  # ToDo: Enable DDOS
  # ddos_protection_plan {
  #   id     = azurerm_network_ddos_protection_plan.vnet-ddos-plan.id
  #   enable = false #Turn this off for now since it is incredibly expensive
  # }

  subnet_service_endpoints = [[],["Microsoft.Storage", "Microsoft.KeyVault"],["Microsoft.Storage"],[]]

  tags                     = local.tags

}
# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.resource_prefix}-nsg"
  location            = var.location
  resource_group_name = module.main_resource_group.resource_group_name

  #Inbound Rules
  security_rule {
    name                       = "Port_443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range    = "443"
    source_address_prefix      = "AzureFrontDoor.Backend"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "65000-65500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    tags = local.tags
}

# App Service Plan (Linux)
resource "azurerm_app_service_plan" "main" {
  name                = "${local.resource_prefix}-asp"
  location            = var.location
  resource_group_name = module.main_resource_group.resource_group_name
  kind                = "Linux"

  sku {
    tier     = var.app_service_tier
    size     = var.app_service_size
    capacity = 1
  }

  reserved = true

  tags = local.tags
}

# Web App (Linux)
resource "azurerm_app_service" "main" {
  name                    = "${local.resource_prefix}-webapp"
  location                = var.location
  app_service_plan_id     = azurerm_app_service_plan.main.id
  resource_group_name     = module.main_resource_group.resource_group_name
  client_affinity_enabled = false
  client_cert_enabled     = false
  https_only              = true
  site_config {
    always_on                 = true
    ftps_state                = "AllAllowed"
    http2_enabled             = false
    linux_fx_version          = "DOCKER"
    min_tls_version           = "1.2"
    use_32_bit_worker_process = true
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]

    cors {
      allowed_origins     = [""]
      support_credentials = false
    }
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags

}
module "storage-account" {
  source                            = ".//modules/storage-account"
  name                              = "${local.resource_prefix}-sto"
  resource_group_name               = module.main_resource_group.resource_group_name
  account_tier                      = "Standard"
  account_replication_type          = "GRS"
  enable_https_traffic_only         = true
  enable_advanced_threat_protection = true
}

# Api Management
#

resource "azurerm_api_management" "poc-apim" {
  name                = "${local.resource_prefix}-apim"
  location            = var.location
  resource_group_name = module.main_resource_group.resource_group_name
  publisher_name      = var.api_management_publisher_name
  publisher_email     = var.api_management_publisher_email
  notification_sender_email = var.api_management_notification_sender_email
  sku_name                  = var.api_management_sku_name
  //subnet_id = module.main_vnet.vnet_subnets[1]

  //network_type = "${networkType}"

  /*network_configuration {
    subnet_id = module.main_vnet.vnet_subnets[1]
  }*/

 # TODO: Verify if this is needed
  security {
    disable_backend_ssl30 = true
    disable_backend_tls10 = true
    disable_backend_tls11 = true

    disable_frontend_ssl30 = true
    disable_frontend_tls10 = true
    disable_frontend_tls11 = true

    disable_triple_des_ciphers = true
  }

  tags = local.tags
}

#
# Health Check API
#
resource "azurerm_api_management_api" "health_check_api" {
  name                = "apim-health-check"
  resource_group_name = module.main_resource_group.resource_group_name
  api_management_name = azurerm_api_management.poc-apim.name
  revision            = "1"
  description         = ""
  display_name        = "APIM Health Check"
  path                = "health"
  protocols           = ["https"]
  service_url         = ""

}
variable "api_protocols" {
  type    = list
  default = ["https"]
}
resource "azurerm_monitor_diagnostic_setting" "poc-apim-ds" {
  name               = "${azurerm_api_management.poc-apim.name}-ds"
  target_resource_id = azurerm_api_management.poc-apim.id
  
  log_analytics_workspace_id = module.log_analytics_workspace.id

  log {
    category = "GatewayLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  } 
  
  metric {
    category = "Gateway Requests"

    retention_policy {
      enabled = false
    }

  }

  metric {
    category = "Capacity"

    retention_policy {
      enabled = false
    }

  } 
}

# Kubernetes cluster (main)
#
resource "azurerm_kubernetes_cluster" "poc-aks" {
  name                = "${local.resource_prefix}-aks"
  resource_group_name = module.main_resource_group.resource_group_name
  location            = module.main_resource_group.location
  dns_prefix          = var.poc_aks_dns_prefix
  kubernetes_version  = var.poc_aks_k8s_version
  node_resource_group = var.poc_aks_node_resource_group_name
  default_node_pool {
    name            = var.poc_aks_agent_pool_name
    enable_auto_scaling = true  
    node_count      = var.poc_aks_agent_pool_node_count
    min_count       = var.poc_aks_agent_pool_node_min_count
    max_count       = var.poc_aks_agent_pool_node_max_count  
    vm_size         = var.poc_aks_agent_pool_vm_size
    os_disk_size_gb = var.poc_aks_agent_pool_os_disk_size_gb
    vnet_subnet_id  = module.main_vnet.vnet_subnets[1]
    type            = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "Standard"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    kube_dashboard {
        enabled                    = true
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = module.log_analytics_workspace.id
    }     
  } 

# 5-27-20: Comment out when running 1st time.  Remove comments after
#  windows_profile {
#     admin_username = "azureuser"
#   }

lifecycle {
    ignore_changes = [
      agent_pool_profile.0.count
    ]
 }

tags = local.tags
}

#
# Application Gateway with WAf V2
#
locals {
 
  # Naming prefix for app gateway components
  vnet_name                      = module.main_vnet.vnet_name
  backend_address_pool_name      = "backend-pool"
  frontend_port_name_http        = "${local.vnet_name}-feport-http"
  frontend_port_name_https       = "${local.vnet_name}-feport-https"
  frontend_ip_configuration_name = "AGW-public-ip-frontend"
  http_setting_name              = "poc-apim-443-setting"
  listener_name                  = "poc-apim-443-listener"
  request_routing_rule_name      = "poc-apim-443-rule"
  redirect_configuration_name    = "${local.vnet_name}-rdrcfg"
}
 
data "azurerm_key_vault" "pockv" {
  name                = "poc-dev-us-c-key"
  resource_group_name = module.main_resource_group.resource_group_name
}

data "azurerm_key_vault_secret" "poccert" {
  name         = "poc-dev-cert"
  key_vault_id = data.azurerm_key_vault.pockv.id
}

output "poccert_pem" {
  value = data.azurerm_key_vault_secret.poccert.value
  sensitive = true
}
 
resource "azurerm_application_gateway" "agw" {
  name                = "${local.resource_prefix}-agw"
  resource_group_name = module.main_resource_group.resource_group_name
  location            = var.location
  enable_http2        = true
 
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }
 
  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }
 
  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = module.main_vnet.vnet_subnets[1]
  }
 
  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }
 
  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }
 
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_address_id  
  }
 
  backend_address_pool {
    name  = local.backend_address_pool_name
    ip_addresses = ["172.${var.network_id}.2.6"]
  }
 
  backend_http_settings {
    name                                = local.http_setting_name
    host_name = "poc-dev-us-c-api.com"
    cookie_based_affinity               = "Enabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = false
    affinity_cookie_name                = "ApplicationGatewayAffinity"
    probe_name                          = "HTTPS"
    connection_draining {
      enabled = true
      drain_timeout_sec = 60
    }
  }
 
  probe {
    pick_host_name_from_backend_http_settings = false
    host = "poc-dev-us-c-api.com"
    interval                                  = 30
    name                                      = "HTTPS"
    protocol                                  = "HTTPS"
    path                                      = "/status-0123456789abcdef"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      status_code = ["200-399"]
      body        = ""
    }
  }
 
  http_listener {
    name                           = "${local.listener_name}"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name_https
    protocol                       = "Https"
    host_name                      = "poc-dev-us-c-api.com"
    require_sni                    = true
    ssl_certificate_name           = "poccert"
  }
 
  request_routing_rule {
    name                       = "${local.request_routing_rule_name}"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = "${local.http_setting_name}"
  }
 
  waf_configuration {
    enabled                  = true
    firewall_mode            = "Prevention" # "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"
    request_body_check       = true
    max_request_body_size_kb = "128"
    file_upload_limit_mb     = "100"
  }
 
  ssl_policy {
    policy_type          = "Custom"
    min_protocol_version = "TLSv1_2"
    cipher_suites = [
      "TLS_RSA_WITH_AES_256_CBC_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
      "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
      "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_RSA_WITH_AES_128_GCM_SHA256",
      "TLS_RSA_WITH_AES_128_CBC_SHA256"
    ]
  }
 
  #TODO: Get real cert
  ssl_certificate {
    name     = "poccert"
    data     = data.azurerm_key_vault_secret.poccert.value
    password = ""
  }
 
  tags = local.tags
}
 
resource "azurerm_monitor_diagnostic_setting" "agw-diagnos" {
  name               = "${azurerm_application_gateway.agw.name}-ds"
  target_resource_id = azurerm_application_gateway.agw.id
  log_analytics_workspace_id = module.log_analytics_workspace.id
 
  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
 
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    enabled  = true
 
    retention_policy {
      enabled = false
    }
 

  } 
  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true
 
    retention_policy {
      enabled = false
    }
 
  } 
 
  metric {
    category = "AllMetrics"
 
    retention_policy {
      enabled = false
    }
 
  }
}
#PIP
resource "azurerm_public_ip" "poc-agw-pip" {
  name                = "${local.resource_prefix}-poc-agw-pip"
  resource_group_name = module.main_resource_group.resource_group_name
  location            = var.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = local.resource_prefix

  tags = local.tags
}
#waf
resource "azurerm_frontdoor_firewall_policy" "waf" {
  name                      = var.waf_policy_name
  resource_group_name       = module.main_resource_group.resource_group_name
  tags                      = local.tags
  enabled                           = true
  mode                              = "Prevention"
  custom_block_response_status_code = 403
  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
  }

}