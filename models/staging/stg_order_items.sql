-- stg_order_items.sql
-- Cleans raw order items data:
--   ✅ Filters out orphaned order references
--   ✅ Filters out zero and negative quantities
--   ✅ Recalculates line_total from quantity * unit_price (fixes mismatches)
--   ✅ Only keeps items with valid product references

with source as (
    select * from {{ source('raw', 'raw_order_items') }}
),

valid_orders as (
    select order_id from {{ ref('stg_orders') }}
),

valid_products as (
    select product_id from {{ ref('stg_products') }}
),

cleaned as (
    select
        oi.item_id,
        oi.order_id,
        oi.product_id,

        -- Cast quantity to integer
        cast(oi.quantity as integer)            as quantity,

        -- Round unit price to 2 decimal places
        round(cast(oi.unit_price as real), 2)   as unit_price,

        -- Recalculate line_total to fix any mismatches
        round(
            cast(oi.quantity as integer) * cast(oi.unit_price as real),
            2
        )                                       as line_total

    from source oi

    -- Only keep items with valid order references
    inner join valid_orders vo
        on oi.order_id = vo.order_id

    -- Only keep items with valid product references
    inner join valid_products vp
        on oi.product_id = vp.product_id

    where
        -- Filter zero and negative quantities
        cast(oi.quantity as integer) > 0
)

select * from cleaned