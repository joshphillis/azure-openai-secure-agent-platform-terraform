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
  description = "Azure region for all resources."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to all resources."
  default     = {}
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the VNet."
}

variable "subnet_cidrs" {
  type = object({
    containerapps = string
    workload      = optional(string)
  })
  description = "CIDR blocks for subnets."
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Optional override for Log Analytics workspace name."
  default     = null
}

variable "acr_name" {
  type        = string
  description = "Optional override for ACR name."
  default     = null
}

variable "acr_sku" {
  type        = string
  description = "ACR SKU (Basic, Standard, Premium)."
  default     = "Basic"
}

variable "kv_name" {
  type        = string
  description = "Optional override for Key Vault name."
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID."
}

variable "openai_name" {
  type        = string
  description = "Optional override for Azure OpenAI resource name."
  default     = null
}

variable "openai_sku" {
  type        = string
  description = "Azure OpenAI SKU (e.g., S0)."
  default     = "S0"
}

variable "openai_deployments" {
  type = list(object({
    name          = string
    model_name    = string
    model_version = string
    scale_type    = string
  }))
  description = "List of Azure OpenAI model deployments."
}

variable "openai_deployment_default" {
  type        = string
  description = "Default OpenAI deployment name."
}

variable "openai_api_key" {
  type        = string
  description = "Azure OpenAI API key (provided via secrets tfvars)."
}

variable "apps" {
  type = list(object({
    name    = string
    image   = string
    cpu     = number
    memory  = string
    env     = map(string)
    secrets = map(string)
  }))
  description = "List of container apps (orchestrator + workers)."
}