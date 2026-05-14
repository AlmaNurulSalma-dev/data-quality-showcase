-- test_email_format.sql
-- Validates that all emails contain @ and a dot after @
-- Expects 0 rows (failures)

select
    customer_id,
    email
from {{ ref('stg_customers') }}
where
    email not like '%@%.%'
    or email like '@%'
    or email like '%@'