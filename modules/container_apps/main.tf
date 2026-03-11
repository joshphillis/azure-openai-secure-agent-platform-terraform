locals {
  apps = {
    for app in var.apps : app.name => app
  }
}

resource "azurerm_container_app" "apps" {
  for_each = local.apps

  name                         = "${var.project_name}-${var.environment}-${each.key}"
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_apps_env_id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.acr_identity_id]
  }

  registry {
    server   = var.acr_server
    identity = var.acr_identity_id
  }

  template {
    container {
      name   = each.key
      image  = each.value.image

      cpu    = each.value.cpu
      memory = each.value.memory

      env {
        for k, v in each.value.env :
        k => v
      }

      env {
        name        = "OPENAI_ENDPOINT"
        value       = var.openai_endpoint
      }

      env {
        name        = "OPENAI_DEPLOYMENT"
        value       = var.openai_deployment_default
      }
    }
  }

  secret {
    for k, v in each.value.secrets :
    k => v
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    app         = each.key
  }
}
