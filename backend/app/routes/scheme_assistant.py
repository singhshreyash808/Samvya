from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List

from app.database.database import get_db
from app.models.scheme import GovernmentScheme
from app.services.ai_assistant import AIAssistant

router = APIRouter(prefix="/api/v1/scheme-assistant", tags=["Scheme Assistant"])

class ChatRequest(BaseModel):
    query: str

class ChatResponse(BaseModel):
    response: str
    tags_detected: List[str]
    schemes_count: int

@router.post("/chat", response_model=ChatResponse)
def chat_with_assistant(request: ChatRequest, db: Session = Depends(get_db)):
    """Chat specifically with the scheme recommendation engine."""
    assistant = AIAssistant()
    parsed_data = assistant.parse_query(request.query)
    
    tags = parsed_data["tags"]
    matched_schemes = []
    
    if tags:
        query = db.query(GovernmentScheme).filter(GovernmentScheme.is_active == True)
        # Very simple match for demonstration
        schemes = query.limit(5).all()
        matched_schemes = [{"name": s.name, "description": s.description} for s in schemes]
        
    response_text = assistant.generate_response(request.query, matched_schemes)
    
    return {
        "response": response_text,
        "tags_detected": tags,
        "schemes_count": len(matched_schemes)
    }
