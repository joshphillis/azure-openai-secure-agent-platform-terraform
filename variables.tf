variable "project_name" {
  type        = string
  description = "Short name for this platform."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "environment" {
  type        = string
  description = "Environment name (dev, prod, etc.)."
}
