import re
from typing import Dict, List

class AIAssistant:
    def __init__(self):
        # Basic hardcoded intent matching for rural use cases.
        # Ideally, this would connect to an LLM like Gemini or OpenAI.
        self.intent_map = {
            "pension": ["pension", "old age", "widow", "senior citizen"],
            "housing": ["house", "housing", "awas", "home", "building"],
            "agriculture": ["farmer", "kisan", "tractor", "crop", "seeds", "fertilizer", "agriculture"],
            "education": ["student", "scholarship", "study", "college", "school", "education"],
            "business": ["business", "msme", "loan", "startup", "shop", "mudra"],
            "health": ["hospital", "health", "treatment", "ayushman", "medicine", "sick"]
        }

    def parse_query(self, query: str) -> Dict[str, any]:
        """
        Parses a natural language query to extract intent tags and profile hints.
        """
        query_lower = query.lower()
        extracted_tags = []
        
        # 1. Identify category tags
        for category, keywords in self.intent_map.items():
            for kw in keywords:
                if re.search(r'\b' + kw + r'\b', query_lower):
                    extracted_tags.append(category)
                    break
                    
        # 2. Extract profile hints (basic NLP)
        profile_hints = {}
        if "farmer" in query_lower or "kisan" in query_lower:
            profile_hints["is_farmer"] = True
        if "student" in query_lower:
            profile_hints["is_student"] = True
        if "widow" in query_lower or "female" in query_lower or "woman" in query_lower:
            profile_hints["gender"] = "Female"
            
        return {
            "query": query,
            "tags": list(set(extracted_tags)),
            "profile_hints": profile_hints
        }

    def generate_response(self, query: str, matched_schemes: List[dict]) -> str:
        """
        Generates a human-friendly response based on matched schemes.
        """
        if not matched_schemes:
            return "I couldn't find specific schemes for your query. Try browsing our categories or give me more details like your occupation."
            
        response = f"Based on what you said, I found {len(matched_schemes)} schemes that might help you. "
        response += "Here are the top matches:\n\n"
        
        for idx, scheme in enumerate(matched_schemes[:3]): # Show top 3
            response += f"• **{scheme['name']}**: {scheme['description'][:100]}...\n"
            
        return response
