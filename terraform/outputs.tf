output "apim_gateway_url" {
  description = "APIM gateway URL — call <apim_gateway_url>/hello to hit the API"
  value       = "${azurerm_api_management.main.gateway_url}/hello"
}

output "function_app_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_linux_function_app.api.default_hostname
}

output "resource_group_name" {
  description = "Name of the resource group containing all resources"
  value       = azurerm_resource_group.main.name
}
