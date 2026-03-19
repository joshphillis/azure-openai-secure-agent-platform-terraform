variable "project_name" {
  type        = string
  description = "Short, lowercase platform name (e.g., 'secure-agent')."
}

variable "environment" {
  type        = string
  description = "Environment identifier (dev, prod, etc.)."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "container_apps_env_id" {
  type        = string
  description = "ID of the Container Apps Environment."
}

variable "acr_server" {
  type        = string
  description = "ACR login server (e.g., secureagentdevacr.azurecr.io)."
}

variable "acr_identity_id" {
  type        = string
  description = "User-assigned identity for ACR pulls."
}

variable "key_vault_id" {
  type        = string
  description = "Key Vault ID for secret references."
}

# ----------------------------------------------------
# OPENAI VARIABLES (correct, deduplicated)
# ----------------------------------------------------
variable "openai_api_key" {
  type        = string
  description = "Azure OpenAI API key"
  sensitive   = true
}

variable "openai_endpoint" {
  type        = string
  description = "Azure OpenAI endpoint URL."
}

variable "openai_deployment_default" {
  type        = string
  description = "Default Azure OpenAI deployment name."
}

# ----------------------------------------------------
# APP DEFINITIONS
# ----------------------------------------------------
variable "apps" {
  type = list(object({
    name    = string
    image   = string
    cpu     = number
    memory  = string
    env     = map(string)
    secrets = map(string)
  }))
  description = "List of container apps to deploy (orchestrator + workers)."
}