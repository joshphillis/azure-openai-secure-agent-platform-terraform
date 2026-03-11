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

variable "openai_name" {
  type        = string
  description = "Optional override for the Azure OpenAI resource name."
  default     = null
}

variable "sku_name" {
  type        = string
  description = "SKU for Azure OpenAI (e.g., 'S0')."
  default     = "S0"
}

variable "deployments" {
  type = list(object({
    name       = string
    model_name = string
    model_version = string
    scale_type = string
  }))
  description = "List of model deployments for Azure OpenAI."
  default     = []
}
