-- test_invalid_ages.sql
-- Validates that all customer ages are between 0 and 120
-- Expects 0 rows (failures)

select
    customer_id,
    age
from {{ ref('stg_customers') }}
where age < 0 or age > 120