from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.database.database import get_db
from app.schemas.scheme_schema import SchemeResponse
from app.services.recommendation_engine import RecommendationEngine
# from app.middleware.auth import get_current_user

router = APIRouter(prefix="/api/v1/recommendations", tags=["Recommendations"])

@router.get("/", response_model=List[dict]) # In real app, use a proper schema
def get_user_recommendations(
    user_id: str = "mock-user-id", # TODO: Use get_current_user dependency
    db: Session = Depends(get_db)
):
    """Get personalized scheme recommendations for the current user."""
    engine = RecommendationEngine(db)
    recommendations = engine.get_recommendations(user_id)
    return recommendations
