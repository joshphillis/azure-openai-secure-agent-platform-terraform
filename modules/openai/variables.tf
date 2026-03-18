variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "openai_name" {
  type    = string
  default = null
}

variable "openai_sku" {
  type        = string
  description = "SKU for the Azure OpenAI resource"
  default     = "S0"
}