data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}


resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                            = var.name
  resource_group_name             = data.azurerm_resource_group.main.name
  location                        = data.azurerm_resource_group.main.location
  offer_type                      = var.offer_type
  kind                            = var.kind
  enable_multiple_write_locations = var.enable_multiple_write_locations
  enable_automatic_failover       = var.enable_automatic_failover
  is_virtual_network_filter_enabled = var.is_virtual_network_filter_enabled
  ip_range_filter                 = var.ip_range_filter
 
  #TODO: Enhance this to Support for multiple VNETs / Subnets
  # virtual_network_rule {
  #   id        =  var.vnet_subnet_id
  # }
  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = var.max_interval_in_seconds
    max_staleness_prefix    = var.max_staleness_prefix
  }
 
 #TODO - Enhance to support multiple Geo Location
  geo_location {
    location          = var.geo_location
    failover_priority = var.failover_priority
  }
 
  tags = merge({
    Terraform = true
    },
    var.tags
  )
  
}