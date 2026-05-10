"""
VaaniSetu Backend - Tamil AI Assistant
Powered by Gemma 4 via Ollama
"""

from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
import base64
import json
import asyncio
from typing import Optional
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="VaaniSetu API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Config ───────────────────────────────────────────────────────────────────
OLLAMA_URL = "http://localhost:11434"
GEMMA_MODEL = "gemma3:4b"   # Use gemma3:12b if you want more quality

# ─── System Prompt ────────────────────────────────────────────────────────────
TAMIL_SYSTEM_PROMPT = """நீங்கள் VaaniSetu என்ற AI உதவியாளர். 
நீங்கள் தமிழ் மக்களுக்காக உருவாக்கப்பட்டீர்கள்.

உங்கள் பணி:
- எப்போதும் தமிழிலேயே பதில் சொல்லுங்கள்
- எளிய, அன்றாட தமிழில் பேசுங்கள் (கடினமான சொற்கள் வேண்டாம்)
- அரசு திட்டங்கள், உடல் நலம், விவசாயம், கல்வி பற்றிய கேள்விகளுக்கு உதவுங்கள்
- ஒவ்வொரு பதிலும் 3-4 வரிகளில் இருக்கட்டும்
- நட்பான தொனியில் பேசுங்கள்

You are VaaniSetu, an AI assistant for Tamil-speaking people in Tamil Nadu.
Always respond in Tamil. Keep answers simple, clear, and helpful.
Focus on: government schemes, health, farming, education, daily needs.
"""

# ─── Models ───────────────────────────────────────────────────────────────────
class ChatRequest(BaseModel):
    message: str
    language: str = "tamil"
    conversation_history: list = []

class ChatResponse(BaseModel):
    response: str
    language: str
    model_used: str

class ImageRequest(BaseModel):
    image_base64: str
    question: str = "இந்த படத்தில் என்ன இருக்கிறது? தமிழில் சொல்லுங்கள்."

# ─── Helper: Call Ollama ──────────────────────────────────────────────────────
async def call_ollama(messages: list, model: str = GEMMA_MODEL) -> str:
    """Call Ollama with Gemma 4 model"""
    async with httpx.AsyncClient(timeout=120.0) as client:
        payload = {
            "model": model,
            "messages": messages,
            "stream": False,
            "options": {
                "temperature": 0.7,
                "num_predict": 512,
            }
        }
        try:
            response = await client.post(
                f"{OLLAMA_URL}/api/chat",
                json=payload
            )
            response.raise_for_status()
            data = response.json()
            return data["message"]["content"]
        except httpx.ConnectError:
            raise HTTPException(
                status_code=503,
                detail="Ollama not running. Please start: ollama serve"
            )
        except Exception as e:
            logger.error(f"Ollama error: {e}")
            raise HTTPException(status_code=500, detail=str(e))

# ─── Routes ──────────────────────────────────────────────────────────────────

@app.get("/")
async def root():
    return {
        "app": "VaaniSetu",
        "tagline": "Tamil AI Assistant - வாணி சேது",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """Check if Ollama + Gemma 4 is running"""
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(f"{OLLAMA_URL}/api/tags")
            models = r.json().get("models", [])
            model_names = [m["name"] for m in models]
            gemma_available = any("gemma" in m for m in model_names)
            return {
                "status": "healthy",
                "ollama": "running",
                "gemma_available": gemma_available,
                "available_models": model_names
            }
    except:
        return {
            "status": "degraded",
            "ollama": "not running",
            "gemma_available": False,
            "fix": "Run: ollama serve && ollama pull gemma3:4b"
        }

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Main Tamil chat endpoint.
    Sends user message to Gemma 4, gets Tamil response.
    """
    # Build conversation
    messages = [{"role": "system", "content": TAMIL_SYSTEM_PROMPT}]

    # Add history (last 6 turns to keep context window small)
    for turn in request.conversation_history[-6:]:
        messages.append(turn)

    # Add current message
    messages.append({
        "role": "user",
        "content": request.message
    })

    logger.info(f"Chat request: {request.message[:50]}...")
    response_text = await call_ollama(messages)
    logger.info(f"Response: {response_text[:50]}...")

    return ChatResponse(
        response=response_text,
        language="tamil",
        model_used=GEMMA_MODEL
    )

@app.post("/analyze-image")
async def analyze_image(request: ImageRequest):
    """
    Multimodal: Analyze image and respond in Tamil.
    Supports: documents, prescriptions, notices, forms
    """
    messages = [
        {"role": "system", "content": TAMIL_SYSTEM_PROMPT},
        {
            "role": "user",
            "content": [
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{request.image_base64}"
                    }
                },
                {
                    "type": "text",
                    "text": request.question
                }
            ]
        }
    ]

    # Use vision-capable model
    response_text = await call_ollama(messages, model="gemma3:4b")

    return {
        "response": response_text,
        "language": "tamil",
        "type": "image_analysis"
    }

@app.get("/topics")
async def get_topics():
    """Return quick-access topic buttons for the app UI"""
    return {
        "topics": [
            {"id": "govt", "tamil": "அரசு திட்டங்கள்", "english": "Government Schemes", "icon": "🏛️"},
            {"id": "health", "tamil": "உடல் நலம்", "english": "Health", "icon": "🏥"},
            {"id": "farming", "tamil": "விவசாயம்", "english": "Farming", "icon": "🌾"},
            {"id": "education", "tamil": "கல்வி", "english": "Education", "icon": "📚"},
            {"id": "rights", "tamil": "உரிமைகள்", "english": "Rights & Legal", "icon": "⚖️"},
            {"id": "emergency", "tamil": "அவசர உதவி", "english": "Emergency Help", "icon": "🚨"},
        ]
    }

@app.post("/quick-question")
async def quick_question(topic_id: str):
    """Generate starter questions for each topic in Tamil"""
    topic_prompts = {
        "govt": "PM கிசான், ஆதார், ரேஷன் கார்டு பற்றிய முக்கிய தகவல்களை தமிழில் சொல்லுங்கள்.",
        "health": "ஆரோக்கியமான வாழ்க்கைக்கான 3 முக்கிய குறிப்புகளை தமிழில் சொல்லுங்கள்.",
        "farming": "தமிழ்நாடு விவசாயிகளுக்கான அரசு திட்டங்கள் என்ன?",
        "education": "மாணவர்களுக்கான உதவித்தொகை திட்டங்கள் என்ன?",
        "rights": "ஒரு குடிமகனின் அடிப்படை உரிமைகள் என்ன?",
        "emergency": "அவசர காலங்களில் அழைக்க வேண்டிய முக்கிய எண்கள் என்ன?"
    }

    prompt = topic_prompts.get(topic_id, "தமிழில் உதவுங்கள்.")
    messages = [
        {"role": "system", "content": TAMIL_SYSTEM_PROMPT},
        {"role": "user", "content": prompt}
    ]

    response_text = await call_ollama(messages)
    return {"response": response_text, "topic": topic_id}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
