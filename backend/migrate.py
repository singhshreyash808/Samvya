"""
Migration script: Add 'balance' column to bank_accounts table if it doesn't exist.
Also adds 'transactions' table if it doesn't exist.
Run from the backend/ directory.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from app.database.database import engine

def run_migrations():
    with engine.connect() as conn:
        # 1. Add balance column to bank_accounts if missing
        result = conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'bank_accounts' AND column_name = 'balance'
        """))
        if result.fetchone() is None:
            print("Adding balance column to bank_accounts...")
            conn.execute(text("""
                ALTER TABLE bank_accounts 
                ADD COLUMN balance FLOAT NOT NULL DEFAULT 50000.0
            """))
            conn.commit()
            print("  OK: balance column added successfully.")
        else:
            print("  INFO: balance column already exists - skipping.")

        # 2. Add 'transactions' table if missing
        result = conn.execute(text("""
            SELECT table_name FROM information_schema.tables
            WHERE table_name = 'transactions' AND table_schema = 'public'
        """))
        if result.fetchone() is None:
            print("Creating transactions table...")
            conn.execute(text("""
                CREATE TABLE transactions (
                    id VARCHAR PRIMARY KEY,
                    sender_account_id VARCHAR NOT NULL REFERENCES bank_accounts(id) ON DELETE CASCADE,
                    recipient_name VARCHAR NOT NULL,
                    recipient_account_number VARCHAR NOT NULL,
                    recipient_bank VARCHAR,
                    amount FLOAT NOT NULL,
                    description VARCHAR,
                    status VARCHAR NOT NULL DEFAULT 'pending',
                    created_at TIMESTAMPTZ DEFAULT now(),
                    updated_at TIMESTAMPTZ DEFAULT now()
                )
            """))
            conn.commit()
            print("  OK: transactions table created successfully.")
        else:
            print("  INFO: transactions table already exists - skipping.")

    print("All migrations completed successfully!")

if __name__ == "__main__":
    run_migrations()
