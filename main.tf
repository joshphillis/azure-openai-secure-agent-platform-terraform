terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "resource_group" {
  source       = "./modules/resource_group"
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  tags         = var.tags
}

module "networking" {
  source              = "./modules/networking"
  location            = var.location
  resource_group_name = module.resource_group.name
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
  project_name        = var.project_name
  environment         = var.environment
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  location            = var.location
  resource_group_name = module.resource_group.name
  workspace_name      = var.log_analytics_workspace_name
  project_name        = var.project_name
  environment         = var.environment
}

module "acr" {
  source              = "./modules/acr"
  location            = var.location
  resource_group_name = module.resource_group.name
  acr_name            = var.acr_name
  sku                 = var.acr_sku
  project_name        = var.project_name
  environment         = var.environment
}

module "key_vault" {
  source              = "./modules/key_vault"
  location            = var.location
  resource_group_name = module.resource_group.name
  kv_name             = var.kv_name
  tenant_id           = var.tenant_id
  project_name        = var.project_name
  environment         = var.environment
}

module "openai" {
  source              = "./modules/openai"
  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = module.resource_group.name
  openai_name         = var.openai_name

  depends_on = [
    module.resource_group
  ]
}

module "container_apps_env" {
  source              = "./modules/container_apps_env"
  location            = var.location
  resource_group_name = module.resource_group.name
  log_analytics_id    = module.log_analytics.workspace_id
  vnet_id             = module.networking.vnet_id
  delegated_subnet_id = module.networking.container_apps_subnet_id
  project_name        = var.project_name
  environment         = var.environment
}

module "container_apps" {
  source                = "./modules/container_apps"
  location              = var.location
  resource_group_name   = module.resource_group.name
  container_apps_env_id = module.container_apps_env.env_id
  acr_server            = module.acr.login_server
  acr_identity_id       = module.acr.identity_id
  key_vault_id          = module.key_vault.id

  # REQUIRED OpenAI variables
  openai_api_key            = var.openai_api_key
  openai_endpoint           = module.openai.endpoint
  openai_deployment_default = var.openai_deployment_default

  # Workers
  apps = var.apps

  # Orchestrator
  orchestrator_image = "${module.acr.login_server}/orchestrator:v4"

  # NEW — pass the real internal DNS domain to the orchestrator
  environment_domain = module.container_apps_env.domain

  project_name = var.project_name
  environment  = var.environment
}