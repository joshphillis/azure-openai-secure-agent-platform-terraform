module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}

module "networking" {
  source              = "./modules/networking"
  location            = var.location
  resource_group_name = module.resource_group.name
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  location            = var.location
  resource_group_name = module.resource_group.name
  workspace_name      = var.log_analytics_workspace_name
}

module "acr" {
  source              = "./modules/acr"
  location            = var.location
  resource_group_name = module.resource_group.name
  acr_name            = var.acr_name
  sku                 = var.acr_sku
}

module "key_vault" {
  source              = "./modules/key_vault"
  location            = var.location
  resource_group_name = module.resource_group.name
  kv_name             = var.kv_name
  tenant_id           = var.tenant_id
}

module "openai" {
  source              = "./modules/openai"
  location            = var.location
  resource_group_name = module.resource_group.name
  openai_name         = var.openai_name
  sku_name            = var.openai_sku
}

module "container_apps_env" {
  source                 = "./modules/container_apps_env"
  location               = var.location
  resource_group_name    = module.resource_group.name
  log_analytics_id       = module.log_analytics.workspace_id
  vnet_id                = module.networking.vnet_id
  delegated_subnet_id    = module.networking.container_apps_subnet_id
}

module "container_apps" {
  source                    = "./modules/container_apps"
  location                  = var.location
  resource_group_name       = module.resource_group.name
  container_apps_env_id     = module.container_apps_env.env_id
  acr_server                = module.acr.login_server
  acr_identity_id           = module.acr.identity_id
  key_vault_id              = module.key_vault.id
  openai_endpoint           = module.openai.endpoint
  openai_deployment_default = var.openai_deployment_default
}
