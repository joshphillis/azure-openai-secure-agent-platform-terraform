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

      dynamic "env" {
        for_each = each.value.env
        content {
          name  = env.key
          value = env.value
        }
      }

      # ----------------------------------------------------
      # OPENAI ENV VARS — NO SECRETS (provider limitation)
      # ----------------------------------------------------
      env {
        name  = "AZURE_OPENAI_API_KEY"
        value = var.openai_api_key
      }

      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = var.openai_endpoint
      }

      env {
        name  = "AZURE_OPENAI_DEPLOYMENT"
        value = var.openai_deployment_default
      }
    }
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    app         = each.key
  }
}

resource "azurerm_container_app" "orchestrator" {
  name                         = "${var.project_name}-${var.environment}-orchestrator"
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
      name   = "orchestrator"
      image  = "${var.acr_server}/orchestrator:latest"
      cpu    = 0.5
      memory = "1Gi"

      command = ["./start.sh"]

      # ----------------------------------------------------
      # OPENAI ENV VARS — NO SECRETS (provider limitation)
      # ----------------------------------------------------
      env {
        name  = "AZURE_OPENAI_API_KEY"
        value = var.openai_api_key
      }

      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = var.openai_endpoint
      }

      env {
        name  = "AZURE_OPENAI_DEPLOYMENT"
        value = var.openai_deployment_default
      }

      env {
        name  = "WORKER_BASE"
        value = "http://localhost"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    app         = "orchestrator"
  }
}