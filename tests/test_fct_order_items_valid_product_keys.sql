-- test_fct_order_items_valid_product_keys.sql
-- Validates that all order items have valid product keys
-- Expects 0 rows (failures)

select
    oi.item_id,
    oi.product_key
from {{ ref('fct_order_items') }} oi
left join {{ ref('dim_products') }} dp
    on oi.product_key = dp.product_key
where oi.product_key is not null
  and dp.product_key is null