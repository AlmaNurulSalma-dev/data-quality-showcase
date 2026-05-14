"""
Data Quality Showcase - Data Generator
========================================
Generates 5 messy data files (CSV, Parquet, JSONL) with intentional
quality issues across 6 dimensions:
  - Completeness (nulls, missing fields)
  - Uniqueness (duplicates)
  - Validity (bad formats, out-of-range values)
  - Consistency (inconsistent casing, categories)
  - Accuracy (wrong calculations, wrong references)
  - Timeliness (future dates, stale records)

Output files:
  data/raw_customers.csv       (25 rows)
  data/raw_products.csv        (21 rows)
  data/raw_orders.csv          (22 rows)
  data/raw_order_items.parquet (15 rows)
  data/raw_events.jsonl        (15 rows)

Usage:
  python scripts/generate_data.py
"""

import os
import json
import random
import pandas as pd
from datetime import datetime, timedelta
from faker import Faker

fake = Faker()
random.seed(42)
Faker.seed(42)

# ─────────────────────────────────────────────
# Output directory
# ─────────────────────────────────────────────
os.makedirs("data", exist_ok=True)


# ─────────────────────────────────────────────
# 1. raw_customers.csv  (25 rows)
# ─────────────────────────────────────────────
def generate_customers():
    """
    Intentional issues:
      - 2 duplicate rows (customer_id 1001 appears twice)
      - 3 null email values
      - 2 invalid ages (negative / >120)
      - Inconsistent status casing ('Active', 'ACTIVE', 'active')
      - 1 null first_name
    """
    statuses = ["active", "inactive", "Active", "ACTIVE", "Inactive"]

    rows = []
    for i in range(1001, 1024):          # 23 unique customers
        age = random.randint(18, 75)

        # Inject invalid ages
        if i in (1005, 1018):
            age = random.choice([-5, 999])

        email = fake.email()
        # Inject null emails
        if i in (1008, 1014, 1020):
            email = None

        first_name = fake.first_name()
        # Inject null first_name
        if i == 1011:
            first_name = None

        rows.append({
            "customer_id":  i,
            "first_name":   first_name,
            "last_name":    fake.last_name(),
            "email":        email,
            "age":          age,
            "status":       random.choice(statuses),
            "created_at":   fake.date_between(start_date="-3y", end_date="today").isoformat(),
            "country":      random.choice(["MY", "SG", "US", "GB", "AU"]),
        })

    # Add 2 duplicate rows (customer_id 1001)
    duplicate = rows[0].copy()
    rows.append(duplicate)
    rows.append(duplicate.copy())

    df = pd.DataFrame(rows)
    df.to_csv("data/raw_customers.csv", index=False)
    print(f"✅ raw_customers.csv  → {len(df)} rows")


# ─────────────────────────────────────────────
# 2. raw_products.csv  (21 rows)
# ─────────────────────────────────────────────
def generate_products():
    """
    Intentional issues:
      - 2 negative prices
      - 1 zero price
      - 2 null product names
      - Inconsistent category casing ('Electronics', 'ELECTRONICS', 'electronics')
    """
    categories = ["Electronics", "ELECTRONICS", "electronics",
                  "Clothing", "CLOTHING", "clothing",
                  "Books", "books",
                  "Home", "HOME"]

    rows = []
    for i in range(2001, 2022):          # 21 products
        price = round(random.uniform(5.0, 500.0), 2)

        # Inject bad prices
        if i == 2003:
            price = -19.99
        elif i == 2010:
            price = -5.00
        elif i == 2017:
            price = 0.00

        name = fake.catch_phrase()
        # Inject null names
        if i in (2007, 2015):
            name = None

        rows.append({
            "product_id":   i,
            "product_name": name,
            "category":     random.choice(categories),
            "price":        price,
            "stock_qty":    random.randint(0, 200),
            "created_at":   fake.date_between(start_date="-2y", end_date="today").isoformat(),
        })

    df = pd.DataFrame(rows)
    df.to_csv("data/raw_products.csv", index=False)
    print(f"✅ raw_products.csv   → {len(df)} rows")


# ─────────────────────────────────────────────
# 3. raw_orders.csv  (22 rows)
# ─────────────────────────────────────────────
def generate_orders():
    """
    Intentional issues:
      - 1 null order_id
      - 2 invalid customer_id references (don't exist in customers)
      - 2 negative total_amount values
      - 2 future order dates
      - Inconsistent status casing
    """
    valid_customer_ids = list(range(1001, 1024))
    statuses = ["pending", "completed", "Completed", "PENDING", "cancelled", "Cancelled"]

    rows = []
    for i in range(3001, 3023):          # 22 orders
        customer_id = random.choice(valid_customer_ids)
        amount      = round(random.uniform(20.0, 1000.0), 2)
        order_date  = fake.date_between(start_date="-1y", end_date="today").isoformat()

        # Inject bad customer references
        if i in (3006, 3014):
            customer_id = random.choice([9999, 8888])

        # Inject negative amounts
        if i in (3009, 3018):
            amount = round(random.uniform(-500.0, -10.0), 2)

        # Inject future dates
        if i in (3011, 3020):
            order_date = (datetime.today() + timedelta(days=random.randint(10, 90))).date().isoformat()

        # Inject null order_id
        order_id = None if i == 3015 else i

        rows.append({
            "order_id":      order_id,
            "customer_id":   customer_id,
            "total_amount":  amount,
            "status":        random.choice(statuses),
            "order_date":    order_date,
            "payment_method": random.choice(["credit_card", "paypal", "bank_transfer", "Credit_Card"]),
        })

    df = pd.DataFrame(rows)
    df.to_csv("data/raw_orders.csv", index=False)
    print(f"✅ raw_orders.csv     → {len(df)} rows")


# ─────────────────────────────────────────────
# 4. raw_order_items.parquet  (15 rows)
# ─────────────────────────────────────────────
def generate_order_items():
    """
    Intentional issues:
      - 2 orphaned order_id references (don't exist in orders)
      - 2 zero/negative quantities
      - 2 unit_price mismatches (wrong product price)
      - 1 line_total calculation mismatch (qty * price ≠ line_total)
    """
    valid_order_ids   = list(range(3001, 3023))
    valid_product_ids = list(range(2001, 2022))

    rows = []
    for i in range(4001, 4016):          # 15 items
        order_id   = random.choice(valid_order_ids)
        product_id = random.choice(valid_product_ids)
        qty        = random.randint(1, 10)
        unit_price = round(random.uniform(5.0, 300.0), 2)
        line_total = round(qty * unit_price, 2)

        # Inject orphaned order references
        if i in (4005, 4012):
            order_id = random.choice([9001, 9002])

        # Inject bad quantities
        if i in (4007, 4010):
            qty = random.choice([0, -3])

        # Inject calculation mismatch
        if i == 4013:
            line_total = round(line_total * 1.5, 2)   # wrong total

        rows.append({
            "item_id":    i,
            "order_id":   order_id,
            "product_id": product_id,
            "quantity":   qty,
            "unit_price": unit_price,
            "line_total": line_total,
        })

    df = pd.DataFrame(rows)
    df.to_parquet("data/raw_order_items.parquet", index=False)
    print(f"✅ raw_order_items.parquet → {len(df)} rows")


# ─────────────────────────────────────────────
# 5. raw_events.jsonl  (15 rows)
# ─────────────────────────────────────────────
def generate_events():
    """
    Intentional issues:
      - 3 null customer_id values
      - 2 invalid event_type values (not in allowed list)
      - 2 future timestamps
      - 1 duplicate event_id
    """
    valid_customer_ids = list(range(1001, 1024))
    valid_event_types  = ["page_view", "add_to_cart", "purchase", "login", "logout"]
    invalid_event_types = ["UNKNOWN", "error_event"]

    records = []
    for i in range(5001, 5016):          # 15 events
        customer_id = random.choice(valid_customer_ids)
        event_type  = random.choice(valid_event_types)
        timestamp   = fake.date_time_between(start_date="-6m", end_date="now").isoformat()

        # Inject null customer_ids
        if i in (5003, 5009, 5013):
            customer_id = None

        # Inject invalid event types
        if i in (5006, 5011):
            event_type = random.choice(invalid_event_types)

        # Inject future timestamps
        if i in (5007, 5014):
            timestamp = (datetime.now() + timedelta(days=random.randint(5, 60))).isoformat()

        records.append({
            "event_id":    i,
            "customer_id": customer_id,
            "event_type":  event_type,
            "timestamp":   timestamp,
            "page":        fake.uri_path(),
            "session_id":  fake.uuid4(),
        })

    # Inject duplicate event_id (repeat record 5001)
    records.append(records[0].copy())

    with open("data/raw_events.jsonl", "w") as f:
        for record in records:
            f.write(json.dumps(record) + "\n")

    print(f"✅ raw_events.jsonl   → {len(records)} rows")


# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────
if __name__ == "__main__":
    print("\n🚀 Generating messy data files...\n")
    generate_customers()
    generate_products()
    generate_orders()
    generate_order_items()
    generate_events()
    print("\n✅ All 5 data files created in data/\n")
    print("Next step: run 'dbt seed' or configure dbt sources to point at these files.")