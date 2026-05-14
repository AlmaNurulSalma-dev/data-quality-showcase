-- dim_products.sql
-- Product dimension table
-- One row per product with enriched attributes

with stg_products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        -- Surrogate key
        row_number() over (order by product_id)     as product_key,

        -- Natural key
        product_id,

        -- Product attributes
        product_name,
        category,
        price,
        stock_qty,
        created_at,

        -- Derived attributes
        case
            when price < 10                         then 'Budget'
            when price between 10 and 49.99         then 'Economy'
            when price between 50 and 199.99        then 'Standard'
            when price between 200 and 499.99       then 'Premium'
            else 'Luxury'
        end                                         as price_tier,

        case
            when stock_qty = 0                      then 'Out of Stock'
            when stock_qty < 10                     then 'Low Stock'
            when stock_qty between 10 and 50        then 'Medium Stock'
            else 'High Stock'
        end                                         as stock_status

    from stg_products
)

select * from final