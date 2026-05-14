-- stg_customers.sql
-- Cleans raw customer data:
--   ✅ Removes duplicate customer_ids (keeps latest)
--   ✅ Filters out null customer_ids
--   ✅ Filters out null emails
--   ✅ Filters invalid ages (keeps 0-120 only)
--   ✅ Normalizes status to lowercase
--   ✅ Trims and lowercases email
--   ✅ Trims first_name and last_name

with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

-- Remove rows with null customer_id
not_null_id as (
    select *
    from source
    where customer_id is not null
),

-- Deduplicate: keep one row per customer_id (pick the first occurrence)
deduplicated as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by customer_id
                order by created_at desc
            ) as row_num
        from not_null_id
    ) ranked
    where row_num = 1
),

-- Apply cleaning transformations
cleaned as (
    select
        customer_id,

        -- Trim whitespace from names
        trim(first_name)                        as first_name,
        trim(last_name)                         as last_name,

        -- Lowercase and trim email, filter nulls
        lower(trim(email))                      as email,

        -- Cast age to integer, keep only valid range
        cast(age as integer)                    as age,

        -- Normalize status to lowercase
        lower(trim(status))                     as status,

        created_at,
        upper(trim(country))                    as country

    from deduplicated
    where
        -- Filter null emails
        email is not null

        -- Filter invalid ages
        and cast(age as integer) between 0 and 120
)

select * from cleaned