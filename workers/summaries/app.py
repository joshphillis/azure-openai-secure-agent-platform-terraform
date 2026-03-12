from fastapi import FastAPI
from pydantic import BaseModel
from openai import AzureOpenAI
import os

app = FastAPI()

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_version="2024-02-01",
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
)

class SummaryRequest(BaseModel):
    text: str

@app.post("/summaries")
async def summarize(req: SummaryRequest):
    response = client.chat.completions.create(
        model=os.getenv("AZURE_OPENAI_DEPLOYMENT"),
        messages=[
            {"role": "system", "content": "Summarize the text concisely."},
            {"role": "user", "content": req.text}
        ]
    )
    return {"summary": response.choices[0].message["content"]}