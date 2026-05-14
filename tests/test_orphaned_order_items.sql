-- test_orphaned_order_items.sql
-- Validates that all order items reference valid orders
-- Expects 0 rows (failures)

select
    oi.item_id,
    oi.order_id
from {{ ref('stg_order_items') }} oi
left join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id
where o.order_id is null