from app.database.database import engine
from sqlalchemy import text

def add_balance_column():
    with engine.connect() as conn:
        try:
            conn.execute(text("ALTER TABLE bank_accounts ADD COLUMN balance FLOAT NOT NULL DEFAULT 50000.0;"))
            conn.commit()
            print("Successfully added 'balance' column to bank_accounts table.")
        except Exception as e:
            print(f"Error (column might already exist): {e}")

if __name__ == "__main__":
    add_balance_column()
