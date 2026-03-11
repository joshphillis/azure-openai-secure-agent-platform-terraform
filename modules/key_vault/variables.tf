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

variable "kv_name" {
  type        = string
  description = "Optional override for the Key Vault name."
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID for access policies."
}
