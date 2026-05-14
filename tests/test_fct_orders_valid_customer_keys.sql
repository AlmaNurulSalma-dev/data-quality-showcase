-- test_fct_orders_valid_customer_keys.sql
-- Validates that all orders in fct_orders have valid customer keys
-- Expects 0 rows (failures)

select
    o.order_id,
    o.customer_key
from {{ ref('fct_orders') }} o
left join {{ ref('dim_customers') }} dc
    on o.customer_key = dc.customer_key
where o.customer_key is not null
  and dc.customer_key is null