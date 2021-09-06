#
# Storage Account Module
#

locals {
  name = "${replace(var.name, "-", "")}"
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "storage" {

  name                              = local.name
  resource_group_name               = data.azurerm_resource_group.main.name
  location                          = data.azurerm_resource_group.main.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  enable_https_traffic_only         = var.enable_https_traffic_only
  enable_advanced_threat_protection = var.enable_advanced_threat_protection
  tags = merge({
    Terraform = true
    },
    var.tags
  )
}

resource "azurerm_storage_share" "file_share" {
  name                 = var.file_share_names[count.index]
  quota                = length(var.file_share_quotas) > 0 ? var.file_share_quotas[count.index] : null
  storage_account_name = azurerm_storage_account.storage.name
  count                = length(var.file_share_names)
}