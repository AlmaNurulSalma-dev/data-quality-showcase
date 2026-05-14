-- test_future_dates.sql
-- Validates that no order dates are in the future
-- Expects 0 rows (failures)

select
    order_id,
    order_date
from {{ ref('stg_orders') }}
where date(order_date) > date('now', 'localtime')