import sqlite3

conn = sqlite3.connect(r'C:\Users\kinet\OneDrive\Documents\PROJECT-ALMAAA\data-quality-showcase\main_marts.db')
tables = ['dim_customers', 'dim_products', 'dim_dates', 'fct_orders', 'fct_order_items', 'fct_events']
print("=== MART ROW COUNTS ===")
for table in tables:
    cursor = conn.execute(f"SELECT COUNT(*) FROM {table}")
    print(f"{table}: {cursor.fetchone()[0]} rows")
conn.close()