"""
load_data.py
============
Loads all raw data files (CSV, Parquet, JSONL) into the SQLite database
so dbt can read them as sources.

Usage:
    py -3.12 scripts/load_data.py
"""

import sqlite3
import pandas as pd
import json
import os

DB_PATH = r"C:\Users\kinet\OneDrive\Documents\PROJECT-ALMAAA\data-quality-showcase\data_quality.db"
DATA_DIR = "data"

def load_csv(conn, filename, table_name):
    df = pd.read_csv(os.path.join(DATA_DIR, filename))
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"✅ Loaded {table_name} → {len(df)} rows")

def load_parquet(conn, filename, table_name):
    df = pd.read_parquet(os.path.join(DATA_DIR, filename))
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"✅ Loaded {table_name} → {len(df)} rows")

def load_jsonl(conn, filename, table_name):
    records = []
    with open(os.path.join(DATA_DIR, filename), "r") as f:
        for line in f:
            records.append(json.loads(line.strip()))
    df = pd.DataFrame(records)
    df.to_sql(table_name, conn, if_exists="replace", index=False)
    print(f"✅ Loaded {table_name} → {len(df)} rows")

if __name__ == "__main__":
    print("\n🚀 Loading raw data into SQLite...\n")

    conn = sqlite3.connect(DB_PATH)

    load_csv(conn, "raw_customers.csv", "raw_customers")
    load_csv(conn, "raw_products.csv", "raw_products")
    load_csv(conn, "raw_orders.csv", "raw_orders")
    load_parquet(conn, "raw_order_items.parquet", "raw_order_items")
    load_jsonl(conn, "raw_events.jsonl", "raw_events")

    conn.close()

    print("\n✅ All tables loaded into SQLite!")
    print(f"   Database: {DB_PATH}")
    print("\nNext step: run 'dbt run --select staging'")