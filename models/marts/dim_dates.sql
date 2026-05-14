-- dim_dates.sql
-- Date dimension table
-- Complete calendar table for the last 3 years + next 1 year

with date_spine as (
    -- Generate a series of dates using recursive CTE
    with recursive dates(date_value) as (
        select date('2023-01-01')
        union all
        select date(date_value, '+1 day')
        from dates
        where date_value < date('2027-12-31')
    )
    select date_value from dates
),

final as (
    select
        -- Date key (integer format YYYYMMDD)
        cast(strftime('%Y%m%d', date_value) as integer)     as date_key,

        -- Date value
        date_value                                          as full_date,

        -- Year
        cast(strftime('%Y', date_value) as integer)         as year,

        -- Quarter
        case
            when cast(strftime('%m', date_value) as integer) between 1 and 3  then 1
            when cast(strftime('%m', date_value) as integer) between 4 and 6  then 2
            when cast(strftime('%m', date_value) as integer) between 7 and 9  then 3
            else 4
        end                                                 as quarter,

        -- Month
        cast(strftime('%m', date_value) as integer)         as month_number,
        case cast(strftime('%m', date_value) as integer)
            when 1  then 'January'
            when 2  then 'February'
            when 3  then 'March'
            when 4  then 'April'
            when 5  then 'May'
            when 6  then 'June'
            when 7  then 'July'
            when 8  then 'August'
            when 9  then 'September'
            when 10 then 'October'
            when 11 then 'November'
            when 12 then 'December'
        end                                                 as month_name,

        -- Week
        cast(strftime('%W', date_value) as integer)         as week_of_year,

        -- Day
        cast(strftime('%d', date_value) as integer)         as day_of_month,
        cast(strftime('%w', date_value) as integer)         as day_of_week,
        case cast(strftime('%w', date_value) as integer)
            when 0 then 'Sunday'
            when 1 then 'Monday'
            when 2 then 'Tuesday'
            when 3 then 'Wednesday'
            when 4 then 'Thursday'
            when 5 then 'Friday'
            when 6 then 'Saturday'
        end                                                 as day_name,

        -- Flags
        case
            when cast(strftime('%w', date_value) as integer) in (0, 6)
            then 1 else 0
        end                                                 as is_weekend,

        case
            when date_value <= date('now', 'localtime')
            then 1 else 0
        end                                                 as is_past_or_today

    from date_spine
)

select * from final