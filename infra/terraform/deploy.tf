# Deploy dos serviços em Azure Container Apps.
# Aplicar em 2 ondas: base (deploy_apps=false) → build-push (imagens) →
# deploy_apps=true (cria os apps abaixo).

locals {
  acr           = azurerm_container_registry.main.login_server
  mysql_fqdn    = azurerm_mysql_flexible_server.main.fqdn
  rabbit_uri    = "amqp://fila:${var.rabbitmq_password}@rabbitmq:5672/"
  rabbit_secret = { "rabbitmq-password" = var.rabbitmq_password }
  db_secret     = { "db-password" = var.mysql_admin_password }
  uri_secret    = { "rabbitmq-uri" = local.rabbit_uri }

  # Env comum a um serviço com MySQL. `db` = nome do banco.
  mysql_env = { for db in var.databases : db => {
    APP_ENV          = "production"
    APP_DEBUG        = "false"
    DB_CONNECTION    = "mysql"
    DB_HOST          = local.mysql_fqdn
    DB_PORT          = "3306"
    DB_DATABASE      = db
    DB_USERNAME      = var.mysql_admin_user
    QUEUE_CONNECTION = "rabbitmq"
    RABBITMQ_HOST    = "rabbitmq"
    RABBITMQ_PORT    = "5672"
    RABBITMQ_USER    = "fila"
  } }

  app_keys = {
    orders       = "base64:90HHtjzVqIp6xS6rCWvDzh5Py0sz08X12VVaU8t8znk="
    inventory    = "base64:+UXjkaiWYMjZFS0wJMTt7KPSvktgPsrccWee9IAKSGk="
    payment      = "base64:77p5Derz1WUE3VUjyVJZGSa+TGoi/rs1qOiAhZV4u20="
    notification = "base64:013l9EZh7SaJv5pSeGxr4etnbq/9sx2rzt+XApMagag="
  }

  apps = {
    # Broker — imagem pública, ingress TCP interno.
    rabbitmq = {
      image_from_acr = false
      image          = "rabbitmq:3-management"
      command        = null
      min            = 1
      max            = 1
      cpu            = 0.5
      memory         = "1Gi"
      ingress        = { external = false, transport = "tcp", target_port = 5672, exposed_port = 5672 }
      env            = { RABBITMQ_DEFAULT_USER = "fila" }
      secret_env     = { RABBITMQ_DEFAULT_PASS = "rabbitmq-password" }
      secrets        = local.rabbit_secret
      scale_queue    = null
    }

    # API HTTP — orquestrador.
    orders = {
      image_from_acr = true
      image          = "${local.acr}/fila-orders:latest"
      command        = ["sh", "-c", "php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000"]
      min            = 1
      max            = 3
      cpu            = 0.25
      memory         = "0.5Gi"
      ingress        = { external = true, transport = "auto", target_port = 8000, exposed_port = null }
      env            = merge(local.mysql_env["orders"], { APP_KEY = local.app_keys.orders })
      secret_env     = { DB_PASSWORD = "db-password", RABBITMQ_PASSWORD = "rabbitmq-password" }
      secrets        = merge(local.db_secret, local.rabbit_secret)
      scale_queue    = null
    }

    "orders-worker" = {
      image_from_acr = true
      image          = "${local.acr}/fila-orders:latest"
      command        = ["sh", "-c", "php artisan queue:work rabbitmq --queue=orders --tries=3"]
      min            = 0
      max            = 5
      cpu            = 0.25
      memory         = "0.5Gi"
      ingress        = null
      env            = merge(local.mysql_env["orders"], { APP_KEY = local.app_keys.orders })
      secret_env     = { DB_PASSWORD = "db-password", RABBITMQ_PASSWORD = "rabbitmq-password" }
      secrets        = merge(local.db_secret, local.rabbit_secret, local.uri_secret)
      scale_queue    = "orders"
    }

    "inventory-worker" = {
      image_from_acr = true
      image          = "${local.acr}/fila-inventory:latest"
      command        = ["sh", "-c", "php artisan migrate --seed --force && php artisan queue:work rabbitmq --queue=inventory --tries=3"]
      min            = 0
      max            = 5
      cpu            = 0.25
      memory         = "0.5Gi"
      ingress        = null
      env            = merge(local.mysql_env["inventory"], { APP_KEY = local.app_keys.inventory })
      secret_env     = { DB_PASSWORD = "db-password", RABBITMQ_PASSWORD = "rabbitmq-password" }
      secrets        = merge(local.db_secret, local.rabbit_secret, local.uri_secret)
      scale_queue    = "inventory"
    }

    "payment-worker" = {
      image_from_acr = true
      image          = "${local.acr}/fila-payment:latest"
      command        = ["sh", "-c", "php artisan migrate --force && php artisan queue:work rabbitmq --queue=payment --tries=3"]
      min            = 0
      max            = 5
      cpu            = 0.25
      memory         = "0.5Gi"
      ingress        = null
      env            = merge(local.mysql_env["payment"], { APP_KEY = local.app_keys.payment })
      secret_env     = { DB_PASSWORD = "db-password", RABBITMQ_PASSWORD = "rabbitmq-password" }
      secrets        = merge(local.db_secret, local.rabbit_secret, local.uri_secret)
      scale_queue    = "payment"
    }

    "notification-worker" = {
      image_from_acr = true
      image          = "${local.acr}/fila-notification:latest"
      command        = ["sh", "-c", "php artisan migrate --force && php artisan queue:work rabbitmq --queue=notification --tries=3"]
      min            = 0
      max            = 5
      cpu            = 0.25
      memory         = "0.5Gi"
      ingress        = null
      env = {
        APP_ENV          = "production"
        APP_DEBUG        = "false"
        APP_KEY          = local.app_keys.notification
        DB_CONNECTION    = "sqlite"
        DB_DATABASE      = "/app/database/database.sqlite"
        QUEUE_CONNECTION = "rabbitmq"
        RABBITMQ_HOST    = "rabbitmq"
        RABBITMQ_PORT    = "5672"
        RABBITMQ_USER    = "fila"
      }
      secret_env  = { RABBITMQ_PASSWORD = "rabbitmq-password" }
      secrets     = merge(local.rabbit_secret, local.uri_secret)
      scale_queue = "notification"
    }
  }

  apps_effective     = var.deploy_apps ? local.apps : {}
  acr_apps_effective = { for k, v in local.apps_effective : k => v if v.image_from_acr }
}

resource "azurerm_container_app" "app" {
  for_each = local.apps_effective

  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = var.tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "registry" {
    for_each = each.value.image_from_acr ? [1] : []
    content {
      server   = local.acr
      identity = "system"
    }
  }

  dynamic "secret" {
    for_each = each.value.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  dynamic "ingress" {
    for_each = each.value.ingress != null ? [each.value.ingress] : []
    content {
      external_enabled = ingress.value.external
      transport        = ingress.value.transport
      target_port      = ingress.value.target_port
      exposed_port     = ingress.value.exposed_port

      traffic_weight {
        latest_revision = true
        percentage      = 100
      }
    }
  }

  template {
    min_replicas = each.value.min
    max_replicas = each.value.max

    container {
      name    = each.key
      image   = each.value.image
      cpu     = each.value.cpu
      memory  = each.value.memory
      command = each.value.command == null ? [] : each.value.command

      dynamic "env" {
        for_each = each.value.env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = each.value.secret_env
        content {
          name        = env.key
          secret_name = env.value
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = each.value.scale_queue != null ? [each.value.scale_queue] : []
      content {
        name             = "rabbitmq-${custom_scale_rule.value}"
        custom_rule_type = "rabbitmq"
        metadata = {
          queueName = custom_scale_rule.value
          mode      = "QueueLength"
          value     = "10"
        }
        authentication {
          secret_name       = "rabbitmq-uri"
          trigger_parameter = "host"
        }
      }
    }
  }
}

# Permite cada app puxar imagem do ACR (pull por managed identity).
resource "azurerm_role_assignment" "acr_pull" {
  for_each = local.acr_apps_effective

  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.app[each.key].identity[0].principal_id
}

output "orders_url" {
  description = "URL pública da API orders (quando deploy_apps=true)."
  value       = var.deploy_apps ? "https://${azurerm_container_app.app["orders"].ingress[0].fqdn}" : null
}
