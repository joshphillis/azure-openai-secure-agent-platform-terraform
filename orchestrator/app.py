from fastapi import FastAPI
import httpx
import os

app = FastAPI()

# Base prefix for all worker internal DNS names
WORKER_BASE = os.getenv("WORKER_BASE", "http://aoai-sec-dev")

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
    async with httpx.AsyncClient(timeout=30.0) as client:
        results = {}

        for worker in WORKERS:
            # Azure Container Apps internal DNS:
            # http://aoai-sec-dev-<worker>:8000/process
            url = f"{WORKER_BASE}-{worker}:8000/process"
            r = await client.post(url, json=payload)
            results[worker] = r.json()

        return {"results": results}