data "azurerm_client_config" "current" {}

# Sufixo aleatório para nomes que precisam ser globalmente únicos
# (ACR, Key Vault, MySQL server).
resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

locals {
  suffix = random_string.suffix.result
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}"
  location = var.location
  tags     = var.tags
}
