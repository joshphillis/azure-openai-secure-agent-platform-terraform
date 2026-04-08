# 🚀 Azure OpenAI Secure Agent Platform (Terraform)

`https://img.shields.io/badge/Terraform-1.5+-5C4EE5`
`https://img.shields.io/badge/Azure-Cloud-blue`
`https://img.shields.io/badge/Azure_OpenAI-GPT--4o_mini-green`
`https://img.shields.io/badge/Azure-Container_Apps-orange`

A secure, event‑driven, multi‑agent document‑intelligence platform deployed on **Azure Container Apps** and fully provisioned using **modular Terraform**. An orchestrator receives a document, fans out work across five specialist AI workers, and aggregates results into a single response — all running privately inside a VNet‑integrated environment.

---

## 🌐 What This Project Demonstrates

This platform was built to showcase **enterprise‑grade AI infrastructure patterns** on Azure:

- Secure AI workloads with **private networking**  
- **Azure OpenAI** with private endpoint + DNS zone  
- **Azure Container Apps** for orchestrator + workers  
- **Parallel fan‑out** multi‑agent architecture  
- **Modular Terraform** for clean, reusable IaC  
- Real‑world CI/CD patterns (GitHub Actions‑ready)  

Submit a document → orchestrator fans out → five workers process in parallel → orchestrator aggregates → unified response returned.

---

## 🧠 Architecture Overview

```
                        Client Request
                              │
                              ▼
                    ┌─────────────────┐
                    │   Orchestrator  │  FastAPI + Azure OpenAI
                    │ (Container App) │  Fan-out + aggregation
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │    Parallel fan-out          │
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │ summaries     │ │ classify     │ │ extract       │
    │ worker        │ │ worker       │ │ worker        │
    └──────────────┘ └──────────────┘ └──────────────┘
              │              │              │
              ▼              ▼              ▼
    ┌──────────────┐ ┌──────────────┐
    │ redact        │ │ translate    │
    │ worker        │ │ worker       │
    └──────────────┘ └──────────────┘
              │
              ▼
        Aggregated Response
```

All services run inside a **VNet‑integrated Container Apps Environment**.  
Workers are resolved via **internal Container Apps DNS** — no public ingress.

---

## 🧩 The Five Specialist Workers

| Worker | Endpoint | Purpose |
|--------|----------|---------|
| `summaries-worker` | `POST /summarize` | Summarizes long‑form text |
| `classify-worker` | `POST /classify` | Classifies text into labels |
| `extract-worker` | `POST /extract` | Extracts structured entities |
| `redact-worker` | `POST /redact` | Redacts PII (email, phone, SSN, etc.) |
| `translate-worker` | `POST /translate` | Translates text to target language |

---

## 🏗️ Infrastructure Components

| Resource | Pattern | Purpose |
|---------|---------|---------|
| Resource Group | `rg-{project}-{env}` | Logical grouping |
| Virtual Network | `vnet-{project}-{env}` | Private networking |
| Container Apps Environment | `cae-{project}-{env}` | VNet‑integrated runtime |
| Azure Container Registry | `acr{project}{env}` | Private image registry |
| Azure OpenAI | `aoai-{project}-{env}` | GPT‑4o mini with private endpoint |
| Key Vault | `kv-{project}-{env}` | Secrets storage |
| Log Analytics | `law-{project}-{env}` | Centralized logs |

---

## 📁 Repository Structure

```
.
├── orchestrator/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
│
├── workers/
│   ├── summaries-worker/
│   ├── classify-worker/
│   ├── extract-worker/
│   ├── redact-worker/
│   └── translate-worker/
│
├── modules/
│   ├── resource_group/
│   ├── networking/
│   ├── acr/
│   ├── key_vault/
│   ├── log_analytics/
│   ├── openai/
│   ├── container_apps_env/
│   └── container_apps/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── build-and-push.ps1
└── terraform.tfvars.example
```

---

## 🔐 Security Hygiene

This repo **never** includes:

- `terraform.tfvars`  
- Terraform state files  
- `.terraform/` directory  

Security design choices:

- Azure OpenAI uses **private endpoint + private DNS zone**  
- ACR admin disabled — **managed identity pulls only**  
- Secrets stored in **Key Vault**, not env vars  
- Container Apps run **inside a VNet**, no public worker endpoints  

---

## 🚀 Deployment Guide

### **Step 1 — Create Terraform State Storage**

```bash
az group create --name rg-tfstate --location eastus

az storage account create \
  --name sttfstate<suffix> \
  --resource-group rg-tfstate \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name sttfstate<suffix>
```

---

### **Step 2 — Configure Variables**

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit:

```hcl
project_name              = "secure-agent"
environment               = "dev"
location                  = "eastus"
tenant_id                 = "<tenant-id>"
openai_api_key            = "<openai-key>"
openai_deployment_default = "gpt-4o-mini"
```

---

### **Step 3 — Deploy Infrastructure**

```bash
terraform init
terraform plan
terraform apply
```

Provisioning takes **10–15 minutes**.

---

### **Step 4 — Build & Push Images**

```powershell
az acr login --name <acr-name>
.\build-and-push.ps1
```

---

### **Step 5 — Test the Platform**

```bash
terraform output container_app_fqdns
```

Health check:

```bash
curl https://<orchestrator-fqdn>/health
```

Full fan‑out:

```bash
curl -X POST https://<orchestrator-fqdn>/run \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Your document text here",
    "labels": ["positive", "negative", "neutral"],
    "sensitive_types": ["name", "email", "phone"],
    "target_language": "Spanish"
  }'
```

---

## 📘 API Reference

### `GET /health`
Returns orchestrator status.

### `POST /run`
Triggers all five workers in parallel.

### Individual Worker Endpoints
- `/summarize`
- `/classify`
- `/extract`
- `/redact`
- `/translate`

Each accepts a simple JSON payload.

---

## 🔄 Rebuild After Destroy

If redeploying:

1. `terraform apply`  
2. `az acr login`  
3. `.\build-and-push.ps1`  

If Azure OpenAI is soft‑deleted:

```bash
az cognitiveservices account purge \
  --name <openai-name> \
  --location <region> \
  --resource-group <resource-group>
```

---

## 🛠️ Troubleshooting

### Workers unreachable
- Internal DNS may still be propagating  
- Check `WORKER_BASE` + `ENVIRONMENT_DOMAIN`  

### Images fail to pull
- Ensure managed identity has **AcrPull**  
- Re‑run build + push  

### OpenAI 401
- Key Vault secret mismatch  
- Check access policies  

### Terraform wants to replace OpenAI
- Usually caused by private endpoint changes  
- Purge soft‑deleted OpenAI resource if needed  

---

## 🧠 What I Learned

- Container Apps internal DNS requires full environment domain  
- Private endpoints need both DNS zone + VNet link  
- ACR managed identity pull is the correct enterprise pattern  
- Terraform `depends_on` is essential for OpenAI + private endpoint ordering  
- Image builds must happen **after** infra deployment  

---

## 🔮 Future Enhancements

- Azure AD auth for orchestrator  
- Async job processing with polling  
- GitHub Actions CI/CD  
- Additional AI workers (embeddings, OCR, etc.)  
- Azure Front Door + WAF  
- Dead‑letter queue for failed worker calls  

---

## 👤 Author

**Joshua Phillis**  
Retired Army National Guard Major • Cloud & Platform Engineer  
GitHub: @joshphillis [(github.com in Bing)](https://www.bing.com/search?q="https%3A%2F%2Fgithub.com%2Fjoshphillis")
