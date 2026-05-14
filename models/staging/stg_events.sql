-- stg_events.sql
with source as (
    select * from {{ source('raw', 'raw_events') }}
),

valid_event_types as (
    select 'page_view'    as event_type union all
    select 'add_to_cart'  as event_type union all
    select 'purchase'     as event_type union all
    select 'login'        as event_type union all
    select 'logout'       as event_type
),

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
        datetime(e.timestamp)   as event_timestamp,
        e.page,
        e.session_id

    from deduplicated e

    inner join valid_event_types vet
        on e.event_type = vet.event_type

    where
        e.customer_id is not null
        and datetime(e.timestamp) <= datetime('now', 'localtime')
)

select * from cleaned