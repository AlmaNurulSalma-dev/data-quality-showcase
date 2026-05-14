-- fct_order_items.sql
-- Order items fact table
-- One row per line item with dimension keys and measures

with stg_order_items as (
    select * from {{ ref('stg_order_items') }}
),

fct_orders as (
    select order_key, order_id from {{ ref('fct_orders') }}
),

dim_products as (
    select product_key, product_id from {{ ref('dim_products') }}
),

final as (
    select
        -- Surrogate key
        row_number() over (order by oi.item_id)         as item_key,

        -- Natural key
        oi.item_id,

        -- Foreign keys
        fo.order_key,
        dp.product_key,

        -- Measures
        oi.quantity,
        oi.unit_price,
        oi.line_total,

        -- Derived measures
        round(oi.line_total * 0.1, 2)                   as estimated_tax,
        round(oi.line_total * 1.1, 2)                   as total_with_tax

    from stg_order_items oi

    left join fct_orders fo
        on oi.order_id = fo.order_id

    left join dim_products dp
        on oi.product_id = dp.product_id
)

select * from final