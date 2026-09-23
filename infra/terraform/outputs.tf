output "resource_group" {
  description = "Nome do resource group."
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Endpoint do Container Registry (para push das imagens)."
  value       = azurerm_container_registry.main.login_server
}

output "key_vault_uri" {
  description = "URI do Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "container_app_environment_id" {
  description = "ID do ambiente Container Apps (usado no deploy da fase 5)."
  value       = azurerm_container_app_environment.main.id
}
