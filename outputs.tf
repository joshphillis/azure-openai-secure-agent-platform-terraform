output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "container_apps_environment_id" {
  value = module.container_apps_env.env_id
}

output "container_app_fqdns" {
  value = module.container_apps.fqdn_map
}

output "openai_endpoint" {
  value = module.openai.endpoint
}
