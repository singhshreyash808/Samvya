from app.models.user_profile import UserProfile
from app.models.scheme import SchemeEligibilityRules

def evaluate_eligibility(user: UserProfile, rules: SchemeEligibilityRules) -> dict:
    """
    Evaluates if a user is eligible for a specific scheme based on its rules.
    Returns a dictionary: {"is_eligible": bool, "missing_criteria": list}
    """
    if not rules:
        # If no rules exist, we assume everyone is eligible or manual checking is needed
        return {"is_eligible": True, "missing_criteria": []}
        
    missing = []
    
    # Check numeric bounds
    if rules.min_age is not None and user.age is not None:
        if user.age < rules.min_age:
            missing.append(f"Minimum age required is {rules.min_age}")
            
    if rules.max_age is not None and user.age is not None:
        if user.age > rules.max_age:
            missing.append(f"Maximum age allowed is {rules.max_age}")
            
    if rules.max_income is not None and user.annual_income > rules.max_income:
        missing.append(f"Maximum annual income allowed is ₹{rules.max_income}")
        
    # Check categorical requirements
    if rules.gender and rules.gender.lower() != 'all':
        if not user.gender or user.gender.lower() != rules.gender.lower():
            missing.append(f"Scheme is restricted to {rules.gender}s only")
            
    if rules.allowed_states and user.state:
        # Assuming comma-separated states "Uttar Pradesh, Bihar"
        states = [s.strip().lower() for s in rules.allowed_states.split(",")]
        if user.state.lower() not in states:
            missing.append(f"Not available in your state. Allowed states: {rules.allowed_states}")
            
    if rules.required_occupations and user.occupation:
        occupations = [o.strip().lower() for o in rules.required_occupations.split(",")]
        if user.occupation.lower() not in occupations:
            missing.append(f"Requires specific occupation: {rules.required_occupations}")
            
    # Check boolean flags
    if rules.requires_farmer and not user.is_farmer:
        missing.append("Requires you to be a Farmer")
    if rules.requires_student and not user.is_student:
        missing.append("Requires you to be a Student")
    if rules.requires_senior_citizen and not user.is_senior_citizen:
        missing.append("Requires you to be a Senior Citizen")
    if rules.requires_business_owner and not user.is_business_owner:
        missing.append("Requires you to be a Business Owner")
    if rules.requires_disability and not user.has_disability:
        missing.append("Requires Disability certification")
    if rules.requires_jan_dhan and not user.has_jan_dhan:
        missing.append("Requires a PM Jan Dhan account")
    if rules.requires_aadhaar and not user.is_aadhaar_linked:
        missing.append("Requires Aadhaar to be linked")
    if rules.requires_land and not user.owns_land:
        missing.append("Requires land ownership")
        
    return {
        "is_eligible": len(missing) == 0,
        "missing_criteria": missing
    }
