output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "domain_name_label" {
  value = azurerm_public_ip.public_ip.domain_name_label
}

output "public_ip_id" {
  value = azurerm_public_ip.public_ip.id
}