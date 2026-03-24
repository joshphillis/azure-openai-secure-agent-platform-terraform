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

# -----------------------------------------------------------
# NEW — required for private endpoint + DNS
# -----------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "ID of the subnet to attach the private endpoint to (workload subnet)."
}

variable "vnet_id" {
  type        = string
  description = "ID of the VNet to link the private DNS zone to."
}
