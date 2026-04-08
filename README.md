# \# Azure OpenAI Secure Agent Platform (Terraform)

# 

# A secure, containerized multi-agent AI platform on Azure Container Apps — an orchestrator routing requests across five specialist AI workers, all privately networked and deployed via Terraform.

# 

# \## What this is

# 

# A document intelligence platform built on Azure Container Apps. Submit a document to the orchestrator and it fans out work in parallel across five specialist workers — all results returned in a single response.

# 

# \*\*Orchestrator\*\* — receives requests, routes to workers in parallel, aggregates results

# 

# \*\*Five specialist workers:\*\*

# \- `summaries-worker` — Summarizes long-form text

# \- `classify-worker` — Classifies text against provided labels

# \- `extract-worker` — Extracts structured entities from documents

# \- `redact-worker` — Redacts sensitive data (PII, SSN, email, phone)

# \- `translate-worker` — Translates text to a target language

# 

# \## Infrastructure Components

# 

# \- Azure Container Apps Environment — VNet-integrated runtime

# \- Azure Container Registry — Private image registry

# \- Azure OpenAI — GPT-4o for AI processing

# \- Key Vault — Secrets storage

# \- Virtual Network — Private networking

# \- Log Analytics — Centralized logging

# 

# \## Security Hygiene

# 

# This repo does not contain terraform.tfvars, terraform.tfstate, or .terraform/ provider binaries. All sensitive data is excluded via .gitignore.

# 

# \## Deployment

# 

# \### Step 1 — Configure variables

# ```bash

# cp terraform.tfvars.example terraform.tfvars

# \# Edit with your values

# ```

# 

# \### Step 2 — Deploy infrastructure

# ```bash

# terraform init

# terraform plan

# terraform apply

# ```

# 

# \### Step 3 — Build and push images

# ```powershell

# az acr login --name <your-acr-name>

# .\\build-and-push.ps1

# ```

# 

# \### Step 4 — Test

# ```bash

# curl -X POST https://<orchestrator-fqdn>/run \\

# &#x20; -H "Content-Type: application/json" \\

# &#x20; -d '{"text": "Your document text here"}'

# ```

# 

# \## API Reference

# 

# \- `GET  /health` — Health check

# \- `POST /run` — Fan-out to all 5 workers in parallel

# \- `POST /summarize` — Summarize text

# \- `POST /classify` — Classify text against labels

# \- `POST /extract` — Extract entities from document

# \- `POST /redact` — Redact sensitive data

# \- `POST /translate` — Translate to target language

# 

# \## Author

# 

# \*\*Joshua Phillis\*\*

# Retired Army National Guard Major (Retired) | Cloud \& Platform Engineer

# GitHub: \[@joshphillis](https://github.com/joshphillis)

