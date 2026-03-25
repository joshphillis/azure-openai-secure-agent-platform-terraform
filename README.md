# Azure OpenAI Secure Agent Platform — Terraform

A production-ready, fully private multi-agent platform on Azure. Deploys an orchestrator and five AI workers (summarize, classify, extract, redact, translate) as Azure Container Apps, all connected to Azure OpenAI via a private endpoint — no public internet exposure for AI traffic.

---

## Architecture Overview

```
                        ┌─────────────────────────────────────────────────┐
                        │                 Azure VNet (10.10.0.0/16)        │
                        │                                                   │
  User / Client         │  ┌─────────────────────────────────────────────┐ │
      │                 │  │     Container Apps Environment (ACA)         │ │
      │ HTTPS           │  │                                               │ │
      ▼                 │  │  ┌─────────────┐     ┌───────────────────┐  │ │
┌─────────────┐         │  │  │Orchestrator │────▶│  summaries-worker │  │ │
│  Public     │─────────┼──┼─▶│  (external) │     │  classify-worker  │  │ │
│  Internet   │         │  │  │             │────▶│  extract-worker   │  │ │
└─────────────┘         │  │  └─────────────┘     │  redact-worker    │  │ │
                        │  │   (containerapps      │  translate-worker │  │ │
                        │  │    subnet)            │  (internal only)  │  │ │
                        │  │                       └────────┬──────────┘  │ │
                        │  └─────────────────────────────── │ ────────────┘ │
                        │                                   │               │
                        │  ┌────────────────────────────────▼─────────────┐ │
                        │  │           Workload Subnet (10.10.2.0/24)      │ │
                        │  │                                               │ │
                        │  │  ┌──────────────────────────────────────────┐│ │
                        │  │  │  Private Endpoint → Azure OpenAI         ││ │
                        │  │  │  privatelink.openai.azure.com DNS Zone   ││ │
                        │  │  └──────────────────────────────────────────┘│ │
                        │  └───────────────────────────────────────────────┘ │
                        └─────────────────────────────────────────────────────┘
```

### Key Design Decisions

- **Private endpoint** for Azure OpenAI — AI traffic never leaves the VNet
- **Internal-only workers** — workers are not publicly accessible; only the orchestrator is exposed
- **Parallel fan-out** — the orchestrator calls all 5 workers simultaneously using `asyncio.gather`
- **VNet-injected Container Apps** — the Container Apps Environment is injected into a dedicated subnet
- **Private DNS Zone** — `privatelink.openai.azure.com` resolves to the private IP inside the VNet

### Resources Deployed

| Resource | Module | Purpose |
|----------|--------|---------|
| Resource Group | `resource_group` | Container for all resources |
| Virtual Network + Subnets | `networking` | Private network isolation |
| Log Analytics Workspace | `log_analytics` | Container Apps logging |
| Azure Container Registry | `acr` | Stores Docker images |
| Key Vault | `key_vault` | Secret management |
| Azure OpenAI | `openai` | GPT model hosting |
| Private Endpoint | `openai` | Private VNet access to OpenAI |
| Private DNS Zone + VNet Link | `openai` | Internal DNS resolution |
| GPT-4o-mini Deployment | `openai` | Model deployment |
| Container Apps Environment | `container_apps_env` | ACA hosting environment |
| Orchestrator Container App | `container_apps` | Routes requests to workers |
| 5 Worker Container Apps | `container_apps` | AI processing workers |

---

## Prerequisites

Before deploying this platform you will need:

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.7.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50.0
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- An active Azure subscription with access to [Azure OpenAI Service](https://aka.ms/oai/access)
- Sufficient quota for `gpt-4o-mini` (GlobalStandard, 10K TPM) in `eastus`

### Azure CLI Login

```bash
az login
az account set --subscription "<your-subscription-id>"
```

---

## Repository Structure

```
.
├── main.tf                          # Root module — wires all modules together
├── variables.tf                     # Root variable declarations
├── outputs.tf                       # Root outputs (FQDNs, resource IDs)
├── versions.tf                      # Terraform version constraints
├── envs/
│   ├── dev.tfvars                   # Non-sensitive variables for dev environment
│   └── dev.secrets.tfvars           # Sensitive variables (gitignored)
├── modules/
│   ├── resource_group/              # Resource group
│   ├── networking/                  # VNet, subnets
│   ├── log_analytics/               # Log Analytics workspace
│   ├── acr/                         # Azure Container Registry + managed identity
│   ├── key_vault/                   # Key Vault + app identity
│   ├── openai/                      # Azure OpenAI + private endpoint + DNS
│   ├── container_apps_env/          # Container Apps Environment
│   └── container_apps/              # Orchestrator + worker Container Apps
├── orchestrator/
│   ├── app.py                       # FastAPI orchestrator
│   ├── Dockerfile
│   ├── requirements.txt
│   └── start.sh
└── workers/
    ├── summaries-worker/            # Summarizes text
    ├── classify-worker/             # Classifies text into labels
    ├── extract-worker/              # Extracts key information
    ├── redact-worker/               # Redacts sensitive data
    └── translate-worker/            # Translates text
```

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/joshphillis/azure-openai-secure-agent-platform-terraform
cd azure-openai-secure-agent-platform-terraform
```

### 2. Create your secrets file

Create `envs/dev.secrets.tfvars` (this file is gitignored — never commit it):

```hcl
openai_api_key = "<your-azure-openai-api-key>"
```

### 3. Review `envs/dev.tfvars`

```hcl
project_name = "aoai-sec"
environment  = "dev"
location     = "eastus"

acr_name  = "<your-unique-acr-name>"
acr_sku   = "Basic"
kv_name   = "<your-unique-kv-name>"
tenant_id = "<your-azure-tenant-id>"

openai_name               = "<your-openai-resource-name>"
openai_deployment_default = "gpt-4o-mini"

vnet_cidr = "10.10.0.0/16"
subnet_cidrs = {
  containerapps = "10.10.1.0/24"
  workload      = "10.10.2.0/24"
}

apps = [
  {
    name         = "summaries-worker"
    image        = "<acr-name>.azurecr.io/summaries-worker:latest"
    cpu          = 0.5
    memory       = "1Gi"
    min_replicas = 1
    max_replicas = 3
    env          = {}
    secrets      = {}
  },
  # ... repeat for classify, extract, redact, translate workers
]
```

### 4. Build and push Docker images

```powershell
az acr login --name <your-acr-name>

# Build and push all workers
.\build-and-push.ps1

# Build and push orchestrator
docker build -t <your-acr-name>.azurecr.io/orchestrator:latest ./orchestrator
docker push <your-acr-name>.azurecr.io/orchestrator:latest
```

### 5. Deploy infrastructure

```bash
terraform init
terraform plan -var-file="envs/dev.tfvars" -var-file="envs/dev.secrets.tfvars"
terraform apply -var-file="envs/dev.tfvars" -var-file="envs/dev.secrets.tfvars"
```

### 6. Test the deployment

Get the orchestrator URL:
```bash
terraform output container_app_fqdns
az containerapp show \
  --name <project>-<env>-orchestrator \
  --resource-group <project>-<env>-rg \
  --query "properties.latestRevisionFqdn" \
  --output tsv
```

Test the health endpoint:
```bash
curl https://<orchestrator-fqdn>/health
```

Test the full pipeline:
```bash
curl -X POST https://<orchestrator-fqdn>/run \
  -H "Content-Type: application/json" \
  -d '{"text": "Artificial intelligence is transforming the world."}'
```

---

## API Reference

### Orchestrator Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/health` | Health check — returns `worker_base` and `environment_domain` |
| `POST` | `/run` | Fan-out to all 5 workers in parallel |
| `POST` | `/summarize` | Call summarize worker only |
| `POST` | `/classify` | Call classify worker only |
| `POST` | `/extract` | Call extract worker only |
| `POST` | `/redact` | Call redact worker only |
| `POST` | `/translate` | Call translate worker only |

### `/run` Request Body

```json
{
  "text": "Your input text here",
  "labels": ["positive", "negative", "neutral"],
  "sensitive_types": ["name", "email", "phone", "ssn"],
  "target_language": "Spanish"
}
```

---

## Module Breakdown

### `modules/openai`
Deploys Azure OpenAI with full private networking. Key resources:
- `azurerm_cognitive_account` — OpenAI account with `public_network_access_enabled = false`
- `azurerm_cognitive_deployment` — GPT-4o-mini model deployment
- `azurerm_private_endpoint` — Attaches OpenAI to the workload subnet
- `azurerm_private_dns_zone` — `privatelink.openai.azure.com`
- `azurerm_private_dns_zone_virtual_network_link` — Links DNS zone to VNet

**Required inputs:** `subnet_id`, `vnet_id`, `openai_deployment_default`

### `modules/container_apps_env`
Deploys the Azure Container Apps managed environment with VNet injection via `infrastructure_subnet_id`. Outputs `default_domain` used by the orchestrator for internal DNS.

### `modules/container_apps`
Deploys the orchestrator (external ingress) and all 5 workers (internal ingress only). Workers receive `AZURE_OPENAI_API_KEY`, `AZURE_OPENAI_ENDPOINT`, and `AZURE_OPENAI_DEPLOYMENT` as environment variables. The orchestrator additionally receives `WORKER_BASE` and `ENVIRONMENT_DOMAIN` for internal DNS routing.

### `modules/networking`
Creates the VNet with two subnets:
- `containerapps` — delegated to `Microsoft.App/environments`
- `workload` — used for private endpoints

### `modules/acr`
Creates Azure Container Registry with a user-assigned managed identity granted `AcrPull` role, used by Container Apps to pull images without storing credentials.

---

## Troubleshooting

### DNS resolution failures from Container Apps to OpenAI
**Symptom:** Workers log `Name or service not known` or connection timeouts to the OpenAI endpoint.

**Cause:** Missing `azurerm_private_dns_zone_virtual_network_link` — the DNS zone exists but isn't linked to the VNet.

**Fix:** Ensure the `modules/openai` module includes the VNet link resource and that `vnet_id` is passed in from the root module.

---

### Workers return 404
**Symptom:** Orchestrator logs show `HTTP error: 404 Not Found` for worker URLs.

**Cause 1:** Wrong URL path — workers expose `/process`, not `/run`.

**Cause 2:** Missing `.internal.` in the DNS hostname. Internal ACA apps resolve as `<app-name>.internal.<environment-domain>`.

**Fix:** Ensure `worker_url()` in `orchestrator/app.py` uses:
```python
f"https://{WORKER_BASE}-{worker_name}.internal.{ENVIRONMENT_DOMAIN}/process"
```

---

### Workers return 301
**Symptom:** Orchestrator logs show `HTTP error: 301` for worker URLs.

**Cause:** Calling workers over `http://` — ACA redirects to `https://`.

**Fix:** Use `https://` in `worker_url()` and add `follow_redirects=True` to the httpx client call.

---

### Workers return 500 / AuthenticationError
**Symptom:** Workers log `openai.AuthenticationError: 401`.

**Cause 1:** Stale API key — if the OpenAI resource was deleted and recreated, the key changes.

**Fix:** Get the new key and update `dev.secrets.tfvars`:
```bash
az cognitiveservices account keys list \
  --name <openai-resource-name> \
  --resource-group <resource-group> \
  --query "key1" --output tsv
```

**Cause 2:** Model deployment doesn't exist.

**Fix:** Ensure `azurerm_cognitive_deployment` is defined in `modules/openai/main.tf` and `openai_deployment_default` is passed through from root.

---

### Soft-deleted OpenAI resource blocks deployment
**Symptom:** `terraform apply` fails with a resource name conflict on the Cognitive Account.

**Cause:** Azure soft-deletes Cognitive Services accounts for up to 48 hours after the resource group is deleted.

**Fix:**
```bash
az cognitiveservices account purge \
  --name <openai-resource-name> \
  --location <region> \
  --resource-group <resource-group>
```

---

### Terraform times out deleting Container Apps Environment
**Symptom:** `context deadline exceeded` during destroy of `azurerm_container_app_environment`.

**Cause:** The managed environment takes 10-15+ minutes to deprovision and Terraform's default timeout is exceeded.

**Fix:** Simply re-run `terraform apply` — Azure continues the deletion in the background and Terraform will reconcile on the next run.

---

## Security Notes

- `dev.secrets.tfvars` is gitignored — never commit API keys
- Azure OpenAI has `public_network_access_enabled = false` — all AI traffic is private
- Workers have `external_enabled = false` — not reachable from the public internet
- ACR uses managed identity for image pulls — no stored credentials
- Consider migrating from API key auth to managed identity for production workloads

---

## License

MIT
