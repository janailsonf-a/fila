# Azure Container Registry — guarda as imagens dos serviços.
resource "azurerm_container_registry" "main" {
  name                = "${var.project}acr${local.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false # acesso por identidade/OIDC, não por admin user
  tags                = var.tags
}
