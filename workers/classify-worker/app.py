from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime
import time
import os
from openai import AzureOpenAI

app = FastAPI()

class ClassifyRequest(BaseModel):
    text: str
    labels: list[str]

from openai import OpenAI

client = OpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    base_url=f"{os.getenv('AZURE_OPENAI_ENDPOINT')}openai/deployments/{os.getenv('AZURE_OPENAI_DEPLOYMENT')}/",
    api_version="2024-02-15-preview"
)

@app.get("/health")
def health():
    return {"status": "healthy", "worker": "classify-worker"}

@app.post("/process")
def process(request: ClassifyRequest):
    start = time.time()

    response = client.chat.completions.create(
        messages=[
            {
                "role": "system",
                "content": f"Classify the text into one of these labels: {request.labels}"
            },
            {"role": "user", "content": request.text}
        ]
    )

    latency_ms = int((time.time() - start) * 1000)

    return {
        "worker": "classify-worker",
        "result": response.choices[0].message.content,
        "model_response": response.dict(),
        "input_tokens": response.usage.prompt_tokens,
        "output_tokens": response.usage.completion_tokens,
        "latency_ms": latency_ms,
        "timestamp": datetime.utcnow().isoformat()
    }