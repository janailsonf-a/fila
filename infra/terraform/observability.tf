# Log Analytics — destino de logs do Container Apps Environment
# (e base para App Insights / Grafana na fase de observability).
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project}-logs"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
