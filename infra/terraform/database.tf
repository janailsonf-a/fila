# MySQL Flexible Server compartilhado, com um banco por microserviço.
# Isolamento por database (dev). Servidores separados por serviço custariam
# ~3x — decisão consciente de custo dentro do crédito Students.
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.project}-mysql-${local.suffix}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = var.mysql_admin_user
  administrator_password = var.mysql_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
  backup_retention_days  = 7
  tags                   = var.tags

  storage {
    size_gb = 20
  }
}

# Um database por serviço.
resource "azurerm_mysql_flexible_database" "service" {
  for_each            = toset(var.databases)
  name                = each.value
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Libera acesso a partir de serviços do Azure (Container Apps).
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow-azure-services"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
