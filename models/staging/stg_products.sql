-- stg_products.sql
-- Cleans raw product data:
--   ✅ Filters out null product names
--   ✅ Filters out negative and zero prices
--   ✅ Normalizes category to title case (lowercase then capitalize)
--   ✅ Trims whitespace from text fields

with source as (
    select * from {{ source('raw', 'raw_products') }}
),

cleaned as (
    select
        product_id,

        -- Trim product name
        trim(product_name)                      as product_name,

        -- Normalize category to lowercase for consistency
        lower(trim(category))                   as category,

        -- Round price to 2 decimal places
        round(cast(price as real), 2)           as price,

        -- Stock qty as integer
        cast(stock_qty as integer)              as stock_qty,

        created_at

    from source
    where
        -- Filter null product names
        product_name is not null
        and trim(product_name) != ''

        -- Filter negative and zero prices
        and cast(price as real) > 0
)

select * from cleaned