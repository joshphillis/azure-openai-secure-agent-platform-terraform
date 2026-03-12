project_name = "azure-openai-secure-agent"
location     = "eastus"
environment  = "dev"

tenant_id = "a8a7d7cc-28f1-4438-a292-bd49c96cd0ab"

openai_deployment_default = "gpt-4o-mini"

openai_deployments = [
  {
    name          = "gpt-4o"
    model_name    = "gpt-4o"
    model_version = "latest"
    scale_type    = "Standard"
  }
]

vnet_cidr = "10.10.0.0/16"

subnet_cidrs = {
  containerapps = "10.10.1.0/24"
}

apps = [
  {
    name   = "summaries-worker"
    image  = "aoaidevacrfbcb.azurecr.io/summaries-worker:latest"
    cpu    = 0.5
    memory = "1Gi"

    env = {
      AZURE_OPENAI_API_KEY    = var.openai_api_key
      AZURE_OPENAI_ENDPOINT   = var.openai_endpoint
      AZURE_OPENAI_DEPLOYMENT = var.openai_deployment_default
    }

    secrets = {}
  }
]

openai_name = "aoai-dev-fbcb8d-alt"