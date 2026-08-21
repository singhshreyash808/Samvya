import asyncio
from sqlalchemy.orm import Session
from app.database.database import SessionLocal, engine, Base
from app.models.scheme import GovernmentScheme, SchemeCategory, SchemeEligibilityRules
from app.models.user import User
from app.models.user_profile import UserProfile

# Ensure tables exist
Base.metadata.create_all(bind=engine)

def seed_db():
    db = SessionLocal()
    
    try:
        # 1. Create Categories
        cat_agri = SchemeCategory(name="Agriculture", description="Schemes for farmers and agriculture")
        cat_health = SchemeCategory(name="Health", description="Healthcare and medical schemes")
        cat_housing = SchemeCategory(name="Housing", description="Housing and shelter schemes")
        cat_women = SchemeCategory(name="Women Empowerment", description="Schemes focusing on women and widows")
        
        db.add_all([cat_agri, cat_health, cat_housing, cat_women])
        db.commit()

        # 2. Create Schemes & Eligibility Rules
        
        # Scheme 1: PM Kisan
        scheme1 = GovernmentScheme(
            name="PM Kisan Samman Nidhi",
            ministry="Ministry of Agriculture",
            category_id=cat_agri.id,
            description="Under the scheme an income support of 6,000/- per year in three equal installments will be provided to all land holding farmer families.",
            benefits="₹6000 per year directly to bank account.",
            application_process="Apply online via PM Kisan portal or visit nearest CSC center.",
            required_documents_text="Aadhaar Card, Land Ownership details, Bank Account details.",
            official_website="https://pmkisan.gov.in/"
        )
        db.add(scheme1)
        db.commit()
        
        rules1 = SchemeEligibilityRules(
            scheme_id=scheme1.id,
            requires_farmer=True,
            requires_land=True,
            requires_aadhaar=True
        )
        db.add(rules1)

        # Scheme 2: Ayushman Bharat
        scheme2 = GovernmentScheme(
            name="Ayushman Bharat PM-JAY",
            ministry="Ministry of Health",
            category_id=cat_health.id,
            description="The world's largest health insurance/ assurance scheme fully financed by the government, provides a cover of Rs. 5 lakhs per family per year.",
            benefits="Health insurance cover of up to ₹5 Lakhs per family.",
            application_process="Check eligibility at Empaneled Hospitals or CSC.",
            required_documents_text="Aadhaar Card, Ration Card."
        )
        db.add(scheme2)
        db.commit()
        
        rules2 = SchemeEligibilityRules(
            scheme_id=scheme2.id,
            max_income=250000.0 # Example constraint
        )
        db.add(rules2)

        # Scheme 3: PMAY
        scheme3 = GovernmentScheme(
            name="Pradhan Mantri Awas Yojana (Gramin)",
            ministry="Ministry of Rural Development",
            category_id=cat_housing.id,
            description="Housing for All by providing pucca houses with basic amenities to all houseless families.",
            benefits="Financial assistance to build a house.",
            application_process="Gram Sabha validates the beneficiary list.",
            required_documents_text="Aadhaar, Bank details, MGNREGA Job Card."
        )
        db.add(scheme3)
        db.commit()
        
        rules3 = SchemeEligibilityRules(
            scheme_id=scheme3.id,
            max_income=300000.0
        )
        db.add(rules3)

        # Scheme 4: Widow Pension
        scheme4 = GovernmentScheme(
            name="Indira Gandhi National Widow Pension Scheme",
            ministry="Ministry of Rural Development",
            category_id=cat_women.id,
            description="Provides pension to widows belonging to Below Poverty Line (BPL) households.",
            benefits="Monthly pension amount varies by state.",
            application_process="Apply through local Gram Panchayat or Block Office.",
            required_documents_text="Death Certificate of husband, Aadhaar, Age Proof."
        )
        db.add(scheme4)
        db.commit()
        
        rules4 = SchemeEligibilityRules(
            scheme_id=scheme4.id,
            min_age=40,
            gender="Female"
        )
        db.add(rules4)

        db.commit()
        
        print("Database seeded successfully with dummy schemes and categories!")
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_db()
