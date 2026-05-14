-- test_positive_prices.sql
-- Validates that all product prices are positive
-- Expects 0 rows (failures)

select
    product_id,
    price
from {{ ref('stg_products') }}
where price <= 0