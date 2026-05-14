-- fct_orders.sql
-- Orders fact table
-- One row per order with dimension keys and metrics

with stg_orders as (
    select * from {{ ref('stg_orders') }}
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
        row_number() over (order by o.order_id)         as order_key,

        -- Natural key
        o.order_id,

        -- Foreign keys to dimensions
        dc.customer_key,
        dd.date_key,

        -- Degenerate dimensions
        o.status                                        as order_status,
        o.payment_method,

        -- Measures
        o.total_amount,

        -- Dates
        o.order_date

    from stg_orders o

    left join dim_customers dc
        on o.customer_id = dc.customer_id

    left join dim_dates dd
        on o.order_date = dd.full_date
)

select * from final