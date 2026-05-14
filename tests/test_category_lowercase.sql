-- test_category_lowercase.sql
-- Validates that all product categories are lowercase (consistency check)
-- Expects 0 rows (failures)

select
    product_id,
    category
from {{ ref('stg_products') }}
where category != lower(category)