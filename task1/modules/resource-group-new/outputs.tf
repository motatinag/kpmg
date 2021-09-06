output "resource_group_name" {
  description = "The name of the resource group that was created."
  value = azurerm_resource_group.main.name
}

output "location" {
  description = "The Azure region where the resource group is located."
  value = azurerm_resource_group.main.location
}