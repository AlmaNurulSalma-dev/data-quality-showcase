-- stg_orders.sql
-- Cleans raw order data:
--   ✅ Filters out null order_ids
--   ✅ Filters out negative and zero total amounts
--   ✅ Filters out future order dates
--   ✅ Normalizes status to lowercase
--   ✅ Normalizes payment_method to lowercase
--   ✅ Only keeps orders with valid customer references

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

valid_customers as (
    select customer_id from {{ ref('stg_customers') }}
),

cleaned as (
    select
        o.order_id,
        o.customer_id,

        -- Round amount to 2 decimal places
        round(cast(o.total_amount as real), 2)  as total_amount,

        -- Normalize status to lowercase
        lower(trim(o.status))                   as status,

        -- Cast order_date to date
        date(o.order_date)                      as order_date,

        -- Normalize payment method to lowercase
        lower(trim(o.payment_method))           as payment_method

    from source o

    -- Only keep orders with valid customer references
    inner join valid_customers vc
        on o.customer_id = vc.customer_id

    where
        -- Filter null order_ids
        o.order_id is not null

        -- Filter negative and zero amounts
        and cast(o.total_amount as real) > 0

        -- Filter future dates
        and date(o.order_date) <= date('now')
)

select * from cleaned