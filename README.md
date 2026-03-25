# **Azure OpenAI Secure Agent Platform — Terraform**

A production‑grade, fully private multi‑agent platform on Azure. This deployment provisions an orchestrator and five AI workers (summaries, classify, extract, redact, translate) running on Azure Container Apps, all communicating with Azure OpenAI **entirely over private networking** — no public exposure for AI traffic.

The platform is designed for secure enterprise workloads, reproducible deployments, and clean separation of concerns across Terraform modules.

---

## **Architecture Overview**

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

---

## **Key Design Principles**

- **Zero‑trust AI traffic** — Azure OpenAI is accessed only through a private endpoint.
- **Internal‑only workers** — workers are not publicly reachable; only the orchestrator has ingress.
- **Parallel fan‑out** — orchestrator dispatches to all workers using `asyncio.gather`.
- **VNet‑injected Container Apps** — ACA environment runs inside a dedicated subnet.
- **Private DNS** — `privatelink.openai.azure.com` resolves to the private endpoint inside the VNet.
- **Reproducible IaC** — entire platform can be rebuilt from scratch using Terraform.

---

## **Resources Deployed**

| Resource | Module | Purpose |
|----------|--------|---------|
| Resource Group | `resource_group` | Logical container |
| Virtual Network + Subnets | `networking` | Private network isolation |
| Log Analytics Workspace | `log_analytics` | ACA diagnostics |
| Azure Container Registry | `acr` | Stores Docker images |
| Key Vault | `key_vault` | Secret storage |
| Azure OpenAI | `openai` | GPT model hosting |
| Private Endpoint | `openai` | Private access to OpenAI |
| Private DNS Zone + Link | `openai` | Internal name resolution |
| GPT‑4o‑mini Deployment | `openai` | Default model |
| Container Apps Environment | `container_apps_env` | VNet‑injected ACA |
| Orchestrator App | `container_apps` | Public entrypoint |
| 5 Worker Apps | `container_apps` | Internal AI microservices |

---

## **Repository Structure**

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── envs/
│   ├── dev.tfvars
│   └── dev.secrets.tfvars
├── modules/
│   ├── resource_group/
│   ├── networking/
│   ├── log_analytics/
│   ├── acr/
│   ├── key_vault/
│   ├── openai/
│   ├── container_apps_env/
│   └── container_apps/
├── orchestrator/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
└── workers/
    ├── summaries-worker/
    ├── classify-worker/
    ├── extract-worker/
    ├── redact-worker/
    └── translate-worker/
```

---

## **Quick Start**

### **1. Clone the repository**

```bash
git clone https://github.com/joshphillis/azure-openai-secure-agent-platform-terraform
cd azure-openai-secure-agent-platform-terraform
```

### **2. Create your secrets file**

`envs/dev.secrets.tfvars` (gitignored):

```hcl
openai_api_key = "<your-azure-openai-api-key>"
```

### **3. Review `envs/dev.tfvars`**

Set project name, ACR name, OpenAI resource name, and VNet CIDRs.

### **4. Build and push Docker images**

```powershell
az acr login --name <acr-name>
.\build-and-push.ps1
```

### **5. Deploy infrastructure**

```bash
terraform init
terraform apply -var-file="envs/dev.tfvars" -var-file="envs/dev.secrets.tfvars"
```

### **6. Test the orchestrator**

```bash
curl https://<orchestrator-fqdn>/health
```

Full pipeline:

```bash
curl -X POST https://<orchestrator-fqdn>/run \
  -H "Content-Type: application/json" \
  -d '{"text": "Artificial intelligence is transforming the world."}'
```

---

## **API Reference**

### **Orchestrator Endpoints**

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Returns environment info |
| POST | `/run` | Fan‑out to all workers |
| POST | `/summarize` | Summaries worker |
| POST | `/classify` | Classification worker |
| POST | `/extract` | Extraction worker |
| POST | `/redact` | Redaction worker |
| POST | `/translate` | Translation worker |

---

## **Module Breakdown**

### **`modules/openai`**
Deploys Azure OpenAI with:

- private endpoint  
- private DNS zone  
- GPT‑4o‑mini deployment  
- public network access disabled  

### **`modules/container_apps_env`**
Creates the VNet‑injected Container Apps Environment.

### **`modules/container_apps`**
Deploys:

- orchestrator (external ingress)  
- 5 workers (internal ingress only)  

Workers receive:

- `AZURE_OPENAI_API_KEY`  
- `AZURE_OPENAI_ENDPOINT`  
- `AZURE_OPENAI_DEPLOYMENT`  

Orchestrator additionally receives:

- `WORKER_BASE`  
- `ENVIRONMENT_DOMAIN`  

---

## **Rebuilding the Entire Platform From Scratch**

This platform can be recreated from an empty subscription using:

```bash
terraform apply -var-file="envs/dev.tfvars" -var-file="envs/dev.secrets.tfvars"
```

Then push images:

```powershell
az acr login --name <acr>
.\build-and-push.ps1
```

This ensures a clean, drift‑free environment every time.

---

## **Common Pitfalls & Fixes**

### **Workers unreachable**
Cause: workers still running old image revision.  
Fix: update image tag → Save → new revision created.

### **OpenAI DNS failures**
Cause: missing VNet link for private DNS zone.  
Fix: ensure `azurerm_private_dns_zone_virtual_network_link` exists.

### **401 AuthenticationError**
Cause: OpenAI resource recreated → API key changed.  
Fix: update `dev.secrets.tfvars`.

### **Soft‑deleted OpenAI resource blocks redeploy**
Fix:

```bash
az cognitiveservices account purge \
  --name <openai-name> \
  --location <region>
```

---

## **What I Learned Building This Platform**

- Azure Container Apps only pulls new images when a **new revision** is created.  
- Internal ACA DNS uses the pattern:  
  `https://<app>.internal.<environment-domain>`  
- Private endpoints require both the endpoint **and** the private DNS zone link.  
- ACR naming consistency is critical across Terraform, Docker, and ACA.  
- `EXPOSE 8000` is required for ACA to detect the container port.  
- Terraform makes full environment rebuilds clean and predictable.

---

## **Future Enhancements**

- Add OpenTelemetry tracing  
- Add Application Insights  
- Add autoscaling rules per worker  
- Add managed identity auth for OpenAI  
- Add CI/CD for Terraform and Docker builds  
- Add multi‑orchestrator agent workflows  

---

## **Security Notes**

- `dev.secrets.tfvars` is gitignored  
- Azure OpenAI has public access disabled  
- Workers have no external ingress  
- ACR uses managed identity for pulls  
- Consider migrating to managed identity for OpenAI  

---

## **License**

MIT
