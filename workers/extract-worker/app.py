from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import time
import os
from openai import AzureOpenAI

app = FastAPI()

class ExtractRequest(BaseModel):
    document: str

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_version="2024-02-15-preview"
)

@app.get("/health")
def health():
    return {"status": "healthy", "worker": "extract-worker"}

@app.post("/process")
def process(request: ExtractRequest):
    start = time.time()

    response = client.chat.completions.create(
        model=os.getenv("AZURE_OPENAI_DEPLOYMENT"),
        messages=[
            {"role": "system", "content": "Extract key information from the document."},
            {"role": "user", "content": request.document}
        ]
    )

    latency_ms = int((time.time() - start) * 1000)

    return {
        "worker": "extract-worker",
        "result": response.choices[0].message.content,
        "model_response": response.dict(),
        "input_tokens": response.usage.prompt_tokens,
        "output_tokens": response.usage.completion_tokens,
        "latency_ms": latency_ms,
        "timestamp": datetime.utcnow().isoformat()
    }