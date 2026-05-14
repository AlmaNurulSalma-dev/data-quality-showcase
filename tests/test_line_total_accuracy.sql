-- test_line_total_accuracy.sql
-- Validates that line_total equals quantity * unit_price
-- Expects 0 rows (failures)

select
    item_id,
    quantity,
    unit_price,
    line_total,
    round(quantity * unit_price, 2) as expected_total
from {{ ref('stg_order_items') }}
where abs(line_total - round(quantity * unit_price, 2)) > 0.01