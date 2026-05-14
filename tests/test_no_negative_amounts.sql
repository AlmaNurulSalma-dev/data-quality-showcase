-- test_no_negative_amounts.sql
-- Validates that all order amounts are positive
-- Expects 0 rows (failures)

select
    order_id,
    total_amount
from {{ ref('stg_orders') }}
where total_amount <= 0