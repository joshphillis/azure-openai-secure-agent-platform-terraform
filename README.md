# \# Azure OpenAI Secure Agent Platform (Terraform)

# Azure OpenAI Secure Agent Platform (Terraform)

![Terraform](https://img.shields.io/badge/Terraform-1.5+-5C4EE5)
![Azure](https://img.shields.io/badge/Azure-Cloud-blue)
![OpenAI](https://img.shields.io/badge/Azure_OpenAI-GPT--4o-green)

A secure, containerized multi-agent AI platform on Azure Container Apps — an orchestrator routing requests across five specialist AI workers, privately networked and deployed via Terraform.

## What this is

A document intelligence platform built on Azure Container Apps. Submit a document to the orchestrator and it fans out work in parallel across five specialist workers — all results returned in a single response.

**Orchestrator** — receives requests, routes to workers in parallel, aggregates results

**Five specialist workers:**

| Worker | What it does |
|---|---|
| `summaries-worker` | Summarizes long-form text |
| `classify-worker` | Classifies text against provided labels |
| `extract-worker` | Extracts structured entities from documents |
| `redact-worker` | Redacts sensitive data (PII, SSN, email, phone) |
| `translate-worker` | Translates text to a target language |

## Infrastructure Components

| Resource | Purpose |
|---|---|
| Azure Container Apps Environment | VNet-integrated runtime for all containers |
| Azure Container Registry | Private image registry |
| Azure OpenAI | GPT-4o for AI processing in each worker |
| Key Vault | Secrets storage for API keys |
| Virtual Network | Private networking with dedicated subnets |
| Log Analytics | Centralized logging and diagnostics |

## Security Hygiene

This repo does not contain `terraform.tfvars`, `terraform.tfstate`, or `.terraform/` provider binaries. All sensitive data is managed locally and excluded via `.gitignore`.

## Deployment

### Step 1 — Configure variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Fill in your tenant_id, openai_api_key, and other values
```

### Step 2 — Deploy infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### Step 3 — Build and push images
```powershell
az acr login --name <your-acr-name>
.\build-and-push.ps1
```

### Step 4 — Test the platform
```bash
# Get orchestrator FQDN from Terraform output
terraform output container_app_fqdns

# Fan-out to all workers at once
curl -X POST https://<orchestrator-fqdn>/run \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Your document text here",
    "labels": ["positive", "negative", "neutral"],
    "sensitive_types": ["name", "email", "phone"],
    "target_language": "Spanish"
  }'
```

## API Reference

| Endpoint | Method | Description |
|---|---|---|
| `/health` | GET | Health check |
| `/run` | POST | Fan-out to all 5 workers in parallel |
| `/summarize` | POST | Summarize text |
| `/classify` | POST | Classify text against labels |
| `/extract` | POST | Extract entities from document |
| `/redact` | POST | Redact sensitive data |
| `/translate` | POST | Translate to target language |

## Author

**Joshua Phillis**
Retired Army National Guard Major | Cloud & Platform Engineer
GitHub: [@joshphillis](https://github.com/joshphillis)
