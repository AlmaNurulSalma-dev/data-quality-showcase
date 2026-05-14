-- dim_customers.sql
-- Customer dimension table
-- One row per active customer with enriched attributes

with stg_customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- Surrogate key
        row_number() over (order by customer_id)    as customer_key,

        -- Natural key
        customer_id,

        -- Customer attributes
        first_name,
        last_name,
        first_name || ' ' || last_name              as full_name,
        email,
        age,
        country,
        status,
        created_at,

        -- Derived attributes
        case
            when age between 0  and 17 then 'Under 18'
            when age between 18 and 24 then '18-24'
            when age between 25 and 34 then '25-34'
            when age between 35 and 44 then '35-44'
            when age between 45 and 54 then '45-54'
            when age between 55 and 64 then '55-64'
            else '65+'
        end                                         as age_group,

        case
            when country in ('MY', 'SG')            then 'Southeast Asia'
            when country in ('US', 'GB', 'AU')      then 'Western'
            else 'Other'
        end                                         as region

    from stg_customers
    where status = 'active'
)

select * from final