from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List

from app.models.scheme import GovernmentScheme
from app.models.user_profile import UserProfile
from app.utils.eligibility_evaluator import evaluate_eligibility

class RecommendationEngine:
    def __init__(self, db: Session):
        self.db = db

    def get_recommendations(self, user_id: str) -> List[dict]:
        """
        Returns a ranked list of scheme dictionaries the user is eligible for.
        """
        # 1. Fetch user profile
        user_profile = self.db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not user_profile:
            return [] # Cannot recommend if profile doesn't exist

        # 2. Fetch active schemes
        schemes = self.db.query(GovernmentScheme).filter(GovernmentScheme.is_active == True).all()
        
        recommended = []
        for scheme in schemes:
            # 3. Evaluate Eligibility
            eval_result = evaluate_eligibility(user_profile, scheme.eligibility_rules)
            
            if eval_result["is_eligible"]:
                # 4. Calculate Base Match Score
                score = self._calculate_match_score(user_profile, scheme)
                
                scheme_dict = {
                    "id": scheme.id,
                    "name": scheme.name,
                    "category_id": scheme.category_id,
                    "category_name": scheme.category.name if scheme.category else "",
                    "description": scheme.description,
                    "is_eligible": True,
                    "match_score": score
                }
                recommended.append(scheme_dict)
                
        # 5. Sort by Match Score Descending
        recommended.sort(key=lambda x: x["match_score"], reverse=True)
        return recommended
        
    def _calculate_match_score(self, user: UserProfile, scheme: GovernmentScheme) -> int:
        score = 50 # Base score for being eligible
        
        # Boost specific matches. e.g. If user is farmer and scheme targets agriculture
        if user.is_farmer and scheme.category and "agricultur" in scheme.category.name.lower():
            score += 20
        if user.is_student and scheme.category and "education" in scheme.category.name.lower():
            score += 20
            
        # Example logic: Newest schemes get a small boost
        # In a real app, integrate SearchHistory and ViewHistory here
        
        return score
