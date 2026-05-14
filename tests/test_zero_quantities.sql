-- test_zero_quantities.sql
-- Validates that all order item quantities are positive
-- Expects 0 rows (failures)

select
    item_id,
    quantity
from {{ ref('stg_order_items') }}
where quantity <= 0