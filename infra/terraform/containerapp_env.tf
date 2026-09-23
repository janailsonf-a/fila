# Ambiente do Azure Container Apps — onde os serviços rodarão (fase 5).
# KEDA já vem embutido; o autoescala por fila do RabbitMQ é configurado
# nos próprios Container Apps na fase de deploy.
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.project}-cae"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = var.tags
}
