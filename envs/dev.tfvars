project_name = "aoai-sec"
environment  = "dev"
location     = "eastus"

# Azure Container Registry
acr_name = "aoaidevacraa06"
acr_sku  = "Basic"

# Key Vault
kv_name   = "aoai-sec-dev-kv"
tenant_id = "a8a7d7cc-28f1-4438-a292-bd49c96cd0ab"

# Azure OpenAI
openai_name                = "aoai-sec-dev-openai"
openai_deployment_default  = "gpt-4o-mini"

# Networking (required)
vnet_cidr = "10.10.0.0/16"

subnet_cidrs = {
  containerapps = "10.10.1.0/24"
  workload      = "10.10.2.0/24"
}

# Worker container apps
apps = [
  {
    name          = "summaries-worker"
    image         = "aoaidevacraa06.azurecr.io/summaries-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
    env           = {}
    secrets       = {}
  },
  {
    name          = "classify-worker"
    image         = "aoaidevacraa06.azurecr.io/classify-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
    env           = {}
    secrets       = {}
  },
  {
    name          = "extract-worker"
    image         = "aoaidevacraa06.azurecr.io/extract-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
    env           = {}
    secrets       = {}
  },
  {
    name          = "redact-worker"
    image         = "aoaidevacraa06.azurecr.io/redact-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
    env           = {}
    secrets       = {}
  },
  {
    name          = "translate-worker"
    image         = "aoaidevacraa06.azurecr.io/translate-worker:latest"
    cpu           = 0.5
    memory        = "1Gi"
    min_replicas  = 1
    max_replicas  = 3
    env           = {}
    secrets       = {}
  }
]