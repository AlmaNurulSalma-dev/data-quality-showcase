-- test_dim_dates_no_gaps.sql
-- Validates that dim_dates covers all dates from 2023 to 2027 with no gaps
-- Expects 0 rows (failures)

select
    count(*) as total_days,
    min(full_date) as min_date,
    max(full_date) as max_date
from {{ ref('dim_dates') }}
having
    total_days != (
        cast(julianday(max(full_date)) - julianday(min(full_date)) as integer) + 1
    )