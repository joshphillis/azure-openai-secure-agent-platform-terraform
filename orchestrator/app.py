from fastapi import FastAPI
import httpx
import os
import asyncio

app = FastAPI()

# Base prefix for all worker internal DNS names
WORKER_BASE = os.getenv("WORKER_BASE", "aoai-sec-dev")

# Azure Container Apps environment name (legacy, no longer used for DNS)
ENVIRONMENT_NAME = os.getenv("ENVIRONMENT_NAME")

# NEW: Actual internal DNS domain for the ACA environment
ENVIRONMENT_DOMAIN = os.getenv("ENVIRONMENT_DOMAIN")

# Worker service names (must match Terraform)
WORKERS = [
    "summaries-worker",
    "classify-worker",
    "extract-worker",
    "redact-worker",
    "translate-worker"
]

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/run")
async def run_job(payload: dict):
    results = {}

    async with httpx.AsyncClient(timeout=10.0) as client:
        for worker in WORKERS:

            # Build the correct worker app name
            worker_name = f"{WORKER_BASE}-{worker}"

            # NEW: Correct Azure Container Apps internal DNS format
            url = f"http://{worker_name}.internal.{ENVIRONMENT_DOMAIN}/process"

            # Retry loop for DNS propagation + worker warmup
            for attempt in range(5):
                try:
                    print(f"[orchestrator] Calling {worker} at {url} (attempt {attempt+1})", flush=True)
                    r = await client.post(url, json=payload)
                    results[worker] = r.json()
                    break

                except httpx.ConnectError as e:
                    print(f"[orchestrator] DNS/Connect error calling {worker}: {e}", flush=True)
                    await asyncio.sleep(2)

                except Exception as e:
                    print(f"[orchestrator] Unexpected error calling {worker}: {e}", flush=True)
                    await asyncio.sleep(2)

            else:
                # All retries failed
                results[worker] = {"error": "worker unreachable after retries"}

    return {"results": results}