# Azure OpenAI Secure Agent Platform (Terraform)

# Azure OpenAI Secure Agent Platform (Terraform)

![Terraform](https://img.shields.io/badge/Terraform-1.5+-5C4EE5)
![Azure](https://img.shields.io/badge/Azure-Cloud-blue)
![OpenAI](https://img.shields.io/badge/Azure_OpenAI-GPT--4o_mini-green)
![Container Apps](https://img.shields.io/badge/Azure-Container_Apps-orange)

A secure, event-driven multi-agent document intelligence platform on **Azure Container Apps** — an orchestrator routing requests across five specialist AI workers, all privately networked and fully deployed via modular Terraform.

---

## What this is

A personal project demonstrating enterprise-grade AI infrastructure on Azure. Submit a document to the orchestrator and it fans out work **in parallel** across five specialist workers — all results aggregated and returned in a single response.

This platform was built to demonstrate:
- Secure AI workload deployment on Azure Container Apps
- Private networking for Azure OpenAI (no public endpoint)
- Modular Terraform infrastructure as code
- Multi-agent orchestration with parallel fan-out
- Real-world CI/CD patterns with GitHub Actions

---

## Architecture

```
                        Client Request
                              │
                              ▼
                    ┌─────────────────┐
                    │   Orchestrator  │  FastAPI + Azure OpenAI
                    │   (Container    │  Routes & aggregates
                    │    App)         │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │    Parallel fan-out          │
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  summaries   │ │   classify   │ │   extract    │
    │   worker     │ │   worker     │ │   worker     │
    └──────────────┘ └──────────────┘ └──────────────┘
              │              │              │
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐
    │    redact    │ │  translate   │
    │    worker    │ │   worker     │
    └──────────────┘ └──────────────┘
              │
              ▼
    Aggregated Response to Client
```

All workers run as Azure Container Apps in a VNet-integrated environment. The orchestrator resolves workers via internal Container Apps DNS — no public endpoints between services.

---

## Five Specialist Workers

| Worker | Endpoint | What it does |
|---|---|---|
| `summaries-worker` | `POST /summarize` | Summarizes long-form text using GPT-4o mini |
| `classify-worker` | `POST /classify` | Classifies text against a provided list of labels |
| `extract-worker` | `POST /extract` | Extracts structured entities from documents |
| `redact-worker` | `POST /redact` | Redacts sensitive data (PII, SSN, email, phone) |
| `translate-worker` | `POST /translate` | Translates text to a specified target language |

---

## Infrastructure Components

| Resource | Name Pattern | Purpose |
|---|---|---|
| Resource Group | `rg-{project}-{env}` | Contains all platform resources |
| Virtual Network | `vnet-{project}-{env}` | Private networking with dedicated subnets |
| Container Apps Environment | `cae-{project}-{env}` | VNet-integrated runtime for all containers |
| Azure Container Registry | `acr{project}{env}` | Private image registry — no public pull |
| Azure OpenAI | `aoai-{project}-{env}` | GPT-4o mini with private endpoint |
| Key Vault | `kv-{project}-{env}` | Secrets storage for API keys |
| Log Analytics | `law-{project}-{env}` | Centralized logging and diagnostics |

---

## Repository Structure

```
.
├── orchestrator/
│   ├── app.py              # FastAPI app — fan-out logic, retry, aggregation
│   ├── Dockerfile
│   └── requirements.txt
├── workers/
│   ├── summaries-worker/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   ├── classify-worker/
│   ├── extract-worker/
│   ├── redact-worker/
│   └── translate-worker/
├── modules/
│   ├── resource_group/     # Resource group
│   ├── networking/         # VNet, subnets (Container Apps + workload)
│   ├── acr/                # Azure Container Registry + managed identity
│   ├── key_vault/          # Key Vault + access policies
│   ├── log_analytics/      # Log Analytics workspace
│   ├── openai/             # Azure OpenAI + private endpoint + DNS zone
│   ├── container_apps_env/ # Container Apps environment (VNet-integrated)
│   └── container_apps/     # Orchestrator + all worker Container Apps
├── main.tf                 # Root module — wires all modules together
├── variables.tf            # Input variable definitions
├── outputs.tf              # Key resource outputs
├── versions.tf             # Provider version constraints
├── build-and-push.ps1      # PowerShell script — builds and pushes all images to ACR
└── terraform.tfvars.example # Example variable values — copy and fill in
```

---

## Security Hygiene

This repo **does not contain**:
- `terraform.tfvars` — environment-specific values and secrets
- `terraform.tfstate` or `terraform.tfstate.backup` — Terraform state
- `.terraform/` — provider binaries and modules cache

All sensitive data is managed locally and excluded via `.gitignore`.

**Security design decisions:**
- Azure OpenAI deployed with a private endpoint — API traffic never traverses the public internet
- ACR admin credentials disabled — images pulled via managed identity
- OpenAI API key stored in Key Vault — never hardcoded or stored in environment variables directly
- VNet-integrated Container Apps environment — workers are not publicly reachable

---

## Prerequisites

- Azure subscription with Contributor access
- Azure CLI: `az login`
- Terraform >= 1.5
- Docker Desktop (for building and pushing images)
- Azure OpenAI quota in your target region

---

## Deployment

### Step 1 — Bootstrap Terraform state storage

```bash
az group create --name rg-tfstate --location eastus
az storage account create \
  --name sttfstate<your-suffix> \
  --resource-group rg-tfstate \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name sttfstate<your-suffix>
```

### Step 2 — Configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
project_name              = "secure-agent"
environment               = "dev"
location                  = "eastus"
tenant_id                 = "<your-tenant-id>"
openai_api_key            = "<your-openai-api-key>"
openai_deployment_default = "gpt-4o-mini"
```

### Step 3 — Deploy infrastructure

```bash
terraform init
terraform plan
terraform apply
```

> Infrastructure takes approximately 10-15 minutes to provision. Azure OpenAI and private endpoint creation are the longest steps.

### Step 4 — Build and push images

```powershell
# Log into ACR
az acr login --name <your-acr-name>

# Build and push all worker images + orchestrator
.\build-and-push.ps1
```

> Run this after `terraform apply` completes — ACR must exist before images can be pushed.

### Step 5 — Test the platform

```bash
# Get the orchestrator FQDN from Terraform output
terraform output container_app_fqdns

# Health check
curl https://<orchestrator-fqdn>/health

# Fan-out to all 5 workers at once
curl -X POST https://<orchestrator-fqdn>/run \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Your document text here",
    "labels": ["positive", "negative", "neutral"],
    "sensitive_types": ["name", "email", "phone"],
    "target_language": "Spanish"
  }'

# Or call individual workers
curl -X POST https://<orchestrator-fqdn>/summarize \
  -H "Content-Type: application/json" \
  -d '{"text": "Your document text here"}'
```

---

## API Reference

### `GET /health`
Returns orchestrator status and environment configuration.

```json
{
  "status": "ok",
  "worker_base": "secure-agent-dev",
  "environment_domain": "internal.example.azurecontainerapps.io"
}
```

### `POST /run`
Fan-out to all 5 workers in parallel. Returns aggregated results.

```json
{
  "text": "string",
  "labels": ["positive", "negative", "neutral"],
  "sensitive_types": ["name", "email", "phone", "ssn"],
  "target_language": "Spanish"
}
```

### `POST /summarize`
```json
{ "text": "string" }
```

### `POST /classify`
```json
{ "text": "string", "labels": ["label1", "label2"] }
```

### `POST /extract`
```json
{ "document": "string" }
```

### `POST /redact`
```json
{ "text": "string", "sensitive_types": ["name", "email"] }
```

### `POST /translate`
```json
{ "text": "string", "target_language": "French" }
```

---

## Rebuilding After Destroy

If you destroy and redeploy the infrastructure:

1. Run `terraform apply` first — this recreates ACR and all infrastructure
2. Run `az acr login --name <acr-name>` to authenticate
3. Run `.\build-and-push.ps1` to rebuild and push all images
4. Container Apps will automatically pull the new images

> Note: Azure OpenAI resources enter a soft-delete state on destroy. If redeploying to the same region with the same name, purge first:
> ```bash
> az cognitiveservices account purge \
>   --name <openai-name> \
>   --location <region> \
>   --resource-group <resource-group>
> ```

---

## Troubleshooting

**Workers returning connection errors**
- Verify the Container Apps environment internal DNS is resolving correctly
- Check `WORKER_BASE` and `ENVIRONMENT_DOMAIN` environment variables on the orchestrator
- Allow 2-3 minutes after deployment for DNS propagation within the environment

**Images failing to pull**
- Confirm ACR managed identity has AcrPull role on the registry
- Re-run `az acr login` and `build-and-push.ps1`

**OpenAI returning 401**
- Verify `openai_api_key` in Key Vault matches the current Azure OpenAI key
- Check Key Vault access policies allow the Container Apps managed identity

**Terraform plan shows OpenAI must be replaced**
- This can happen with private endpoint changes — review carefully before applying
- If the resource is being destroyed and recreated, purge the soft-deleted OpenAI resource first

---

## What I Learned Building This

- Azure Container Apps internal DNS resolution requires the full environment domain — the orchestrator must know `ENVIRONMENT_DOMAIN` at runtime to construct correct worker URLs
- Private endpoints for Azure OpenAI require both a private DNS zone and a VNet link — missing either causes silent resolution failures
- ACR admin credentials should never be used — managed identity pull is the correct pattern and works seamlessly with Container Apps
- Terraform's `depends_on` is essential when OpenAI private endpoints depend on VNet resources that may not be fully provisioned yet
- Building and pushing images must happen **after** `terraform apply` — ACR doesn't exist until infrastructure is deployed

---

## Future Enhancements

- Add Azure AD authentication to the orchestrator public endpoint
- Implement async task processing with job ID and status polling
- Add GitHub Actions CI/CD pipeline for automated image builds and deployments
- Expand worker capabilities with additional AI models (GPT-4o, embeddings)
- Add Azure Front Door for global load balancing and WAF protection
- Implement dead-letter handling for failed worker calls

---

## Author

**Joshua Phillis**
Retired Army National Guard Major | Cloud & Platform Engineer
GitHub: [@joshphillis](https://github.com/joshphillis)
