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
