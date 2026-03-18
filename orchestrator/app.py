from fastapi import FastAPI
import httpx
import os

app = FastAPI()

WORKER_BASE = os.getenv("WORKER_BASE", "http://localhost")  # overridden in Container Apps

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/run")
async def run_job(payload: dict):
    async with httpx.AsyncClient(timeout=30.0) as client:
        results = {}

        for worker in ["summaries-worker", "classify-worker", "extract-worker", "redact-worker", "translate-worker"]:
            url = f"{WORKER_BASE}/{worker}/process"
            r = await client.post(url, json=payload)
            results[worker] = r.json()

        return {"results": results}