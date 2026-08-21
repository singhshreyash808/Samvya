from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List

from app.database.database import get_db
from app.models.scheme import GovernmentScheme, SchemeCategory
from app.schemas.scheme_schema import SchemeResponse, SchemeDetailResponse, CategoryResponse
# Assuming get_current_user exists in your auth module
# from app.middleware.auth import get_current_user 

router = APIRouter(prefix="/api/v1/schemes", tags=["Schemes"])

@router.get("/categories", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    """Fetch all scheme categories."""
    categories = db.query(SchemeCategory).all()
    return categories

@router.get("/", response_model=List[SchemeResponse])
def get_schemes(
    category_id: str = Query(None, description="Filter by Category ID"),
    search: str = Query(None, description="Search by name or description"),
    db: Session = Depends(get_db)
):
    """Fetch government schemes with optional filters."""
    query = db.query(GovernmentScheme).filter(GovernmentScheme.is_active == True)
    
    if category_id:
        query = query.filter(GovernmentScheme.category_id == category_id)
        
    if search:
        search_pattern = f"%{search}%"
        query = query.filter(
            (GovernmentScheme.name.ilike(search_pattern)) | 
            (GovernmentScheme.description.ilike(search_pattern))
        )
        
    return query.all()

@router.get("/{scheme_id}", response_model=SchemeDetailResponse)
def get_scheme_details(scheme_id: str, db: Session = Depends(get_db)):
    """Fetch full details of a specific scheme including eligibility rules."""
    scheme = db.query(GovernmentScheme).filter(GovernmentScheme.id == scheme_id).first()
    if not scheme:
        raise HTTPException(status_code=404, detail="Scheme not found")
    return scheme
