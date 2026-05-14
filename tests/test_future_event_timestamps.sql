-- test_future_event_timestamps.sql
-- Validates that no event timestamps are in the future
-- Expects 0 rows (failures)

select
    event_id,
    event_timestamp
from {{ ref('stg_events') }}
where datetime(event_timestamp) > datetime('now', 'localtime')