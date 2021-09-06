output "id" {
  description = "Object id of the Application Insights resource."
  value       = "${azurerm_application_insights.this.id}"
}

output "instrumentation_key" {
  description = "Instrumentation key for the Application Insights resource."
  value       = "${azurerm_application_insights.this.instrumentation_key}"
}

