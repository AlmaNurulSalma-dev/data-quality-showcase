-- fct_events.sql
-- Events fact table
-- One row per event with dimension keys and attributes

with stg_events as (
    select * from {{ ref('stg_events') }}
),

dim_customers as (
    select customer_key, customer_id from {{ ref('dim_customers') }}
),

dim_dates as (
    select date_key, full_date from {{ ref('dim_dates') }}
),

final as (
    select
        -- Surrogate key
        row_number() over (order by e.event_id)         as event_key,

        -- Natural key
        e.event_id,

        -- Foreign keys
        dc.customer_key,
        dd.date_key,

        -- Event attributes
        e.event_type,
        e.event_timestamp,
        e.page,
        e.session_id,

        -- Derived attributes
        date(e.event_timestamp)                         as event_date,
        strftime('%H', e.event_timestamp)               as event_hour,

        case
            when cast(strftime('%H', e.event_timestamp) as integer) between 6  and 11 then 'Morning'
            when cast(strftime('%H', e.event_timestamp) as integer) between 12 and 17 then 'Afternoon'
            when cast(strftime('%H', e.event_timestamp) as integer) between 18 and 21 then 'Evening'
            else 'Night'
        end                                             as time_of_day

    from stg_events e

    left join dim_customers dc
        on e.customer_id = dc.customer_id

    left join dim_dates dd
        on date(e.event_timestamp) = dd.full_date
)

select * from final