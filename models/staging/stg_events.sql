-- stg_events.sql
-- Cleans raw events data:
--   ✅ Removes duplicate event_ids (keeps first occurrence)
--   ✅ Filters out null customer_ids
--   ✅ Filters out invalid event types
--   ✅ Filters out future timestamps
--   ✅ Only keeps events with valid customer references

with source as (
    select * from {{ source('raw', 'raw_events') }}
),

valid_customers as (
    select customer_id from {{ ref('stg_customers') }}
),

-- Allowed event types
valid_event_types as (
    select 'page_view'    as event_type union all
    select 'add_to_cart'  as event_type union all
    select 'purchase'     as event_type union all
    select 'login'        as event_type union all
    select 'logout'       as event_type
),

-- Deduplicate event_ids
deduplicated as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by event_id
                order by timestamp asc
            ) as row_num
        from source
        where event_id is not null
    ) ranked
    where row_num = 1
),

cleaned as (
    select
        e.event_id,
        e.customer_id,
        e.event_type,

        -- Cast timestamp
        datetime(e.timestamp)                   as event_timestamp,

        e.page,
        e.session_id

    from deduplicated e

    -- Only keep events with valid customer references
    inner join valid_customers vc
        on e.customer_id = vc.customer_id

    -- Only keep valid event types
    inner join valid_event_types vet
        on e.event_type = vet.event_type

    where
        -- Filter null customer_ids
        e.customer_id is not null

        -- Filter future timestamps
        and datetime(e.timestamp) <= datetime('now')
)

select * from cleaned