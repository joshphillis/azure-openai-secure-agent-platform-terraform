project_name = "aoai-sec"
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
    image  = "aoaidevacraa06.azurecr.io/summaries-worker:latest"
    cpu    = 0.5
    memory = "1Gi"

    env = {
      AZURE_OPENAI_API_KEY    = ""
      AZURE_OPENAI_ENDPOINT   = "https://aoai-dev-fbcb8d-001.openai.azure.com/"
      AZURE_OPENAI_DEPLOYMENT = "gpt-4o-mini"
    }

    secrets = {}
  }
]

openai_name = "aoai-dev-fbcb8d-001"