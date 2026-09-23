# Azure Container Registry — guarda as imagens dos serviços.
resource "azurerm_container_registry" "main" {
  name                = "${var.project}acr${local.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  # Admin user habilitado: o env de Container Apps da Students não suporta
  # pull por managed identity ("express environment"), então os apps puxam
  # com usuário/senha do ACR (guardados como secret no app).
  admin_enabled = true
  tags          = var.tags
}
