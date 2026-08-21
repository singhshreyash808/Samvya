import os
import google.generativeai as genai
from fastapi import APIRouter
from pydantic import BaseModel
from dotenv import load_dotenv

load_dotenv()

router = APIRouter(
    prefix="/assistant",
    tags=["Assistant"]
)

class QueryRequest(BaseModel):
    query: str
    language: str = "en"

api_key = os.getenv("ASSISTANT_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

@router.post("/query")
def process_query(request: QueryRequest):
    query = request.query
    lang = request.language
    
    if not api_key:
        return fallback_logic(query, lang, "API key not configured.")
        
    language_map = {
        "en": "English",
        "hi": "Hindi",
        "or": "Odia",
        "ta": "Tamil"
    }
    
    target_lang = language_map.get(lang, "English")
    
    prompt = f"""
You are Samvya, a helpful, polite, and smart voice assistant for a rural banking application.
The user is asking a question or giving a command.
You must answer concisely, naturally, and in {target_lang}.
Do NOT use markdown, asterisks, bullet points, or special characters in the "response" text.

IMPORTANT: You MUST return your answer as a valid JSON object with EXACTLY this structure:
{{
  "response": "Your spoken text here",
  "action": "navigate" or "none",
  "target": "home" or "money" or "scan" or "schemes" or "profile" or "none"
}}

User says: {query}
"""
    
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content(prompt)
        response_text = response.text.strip()
        
        # Clean up markdown if Gemini adds it
        if response_text.startswith("```json"):
            response_text = response_text[7:]
        elif response_text.startswith("```"):
            response_text = response_text[3:]
        if response_text.endswith("```"):
            response_text = response_text[:-3]
        
        import json
        try:
            data = json.loads(response_text.strip())
            return {
                "success": True,
                "response": data.get("response", ""),
                "action": data.get("action", "none"),
                "target": data.get("target", "none")
            }
        except json.JSONDecodeError:
            # Fallback if it didn't return valid JSON
            return {
                "success": True,
                "response": response_text,
                "action": "none",
                "target": "none"
            }
            
    except Exception as e:
        print(f"Gemini API Error: {e}")
        return fallback_logic(query, lang, f"The AI brain is unavailable. Error: {str(e)}")

def fallback_logic(query: str, lang: str, reason: str = ""):
    query = query.lower()
    responses = {
        "en": {
            "fallback": f"I heard you say: '{query}'. But I cannot process it right now."
        },
        "hi": {
            "fallback": f"मैंने आपको यह कहते सुना: '{query}'। लेकिन मैं अभी इसे प्रोसेस नहीं कर सकता।"
        },
        "or": {
            "fallback": f"ମୁଁ ଶୁଣିଲି ଆପଣ କହିଲେ: '{query}'। କିନ୍ତୁ ମୁଁ ବର୍ତ୍ତମାନ ଏହାକୁ ପ୍ରକ୍ରିୟାକରଣ କରିପାରିବି ନାହିଁ |"
        },
        "ta": {
            "fallback": f"நீங்கள் கூறியதை நான் கேட்டேன்: '{query}'. ஆனால் தற்போது அதைச் செயல்படுத்த முடியவில்லை."
        }
    }
    
    if lang not in responses:
        lang = "en"
        
    return {
        "success": True,
        "response": responses[lang]["fallback"],
        "action": "none",
        "target": "none"
    }
