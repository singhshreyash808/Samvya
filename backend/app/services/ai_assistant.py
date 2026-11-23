import re
import os
import google.generativeai as genai
from typing import Dict, List
from dotenv import load_dotenv

load_dotenv()

class AIAssistant:
    def __init__(self):
        self.api_key = os.getenv("ASSISTANT_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-3.5-flash')
        else:
            self.model = None

        # Basic hardcoded intent matching for rural use cases.
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
        Generates a human-friendly response using Gemini AI if available.
        """
        if self.model:
            schemes_text = "\n".join([f"- {s['name']}: {s['description']}" for s in matched_schemes])
            
            prompt = f"""
You are Samvya, a helpful AI assistant for a government schemes and rural banking application.
The user asked: "{query}"

We have found these relevant schemes in our database that match their tags (if any):
{schemes_text if schemes_text else "None"}

Please answer the user's query naturally, politely, and concisely. 
If they just said a greeting like "hello", just say hello back and ask how you can help them find schemes today.
If they asked a specific question and we provided schemes, summarize how those schemes can help them. 
If no schemes matched, ask them for more details like their occupation, age, or state so you can help them better.
"""
            try:
                response = self.model.generate_content(prompt)
                return response.text.strip()
            except Exception as e:
                print(f"Gemini API Error: {e}")
                # Fallback to hardcoded if API fails
                pass

        # Fallback if no model or if API failed
        if not matched_schemes:
            return "I couldn't find specific schemes for your query. Try browsing our categories or give me more details like your occupation."
            
        response = f"Based on what you said, I found {len(matched_schemes)} schemes that might help you. "
        response += "Here are the top matches:\n\n"
        
        for idx, scheme in enumerate(matched_schemes[:3]): # Show top 3
            response += f"• **{scheme['name']}**: {scheme['description'][:100]}...\n"
            
        return response
