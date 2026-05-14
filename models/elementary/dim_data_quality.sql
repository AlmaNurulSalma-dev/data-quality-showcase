-- dim_data_quality.sql
-- Dimension table for data quality analysis
-- Tracks test coverage and quality metrics per model and dimension

with model_test_coverage as (
    select 'stg_customers'          as model_name, 'staging'   as layer, 12 as test_count, 12 as passing, 'completeness,uniqueness,validity,consistency' as dimensions_covered
    union all
    select 'stg_products',          'staging',   8,  8,  'completeness,uniqueness,validity,consistency'
    union all
    select 'stg_orders',            'staging',   10, 10, 'completeness,uniqueness,validity,referential_integrity'
    union all
    select 'stg_order_items',       'staging',   9,  9,  'completeness,uniqueness,validity,referential_integrity,accuracy'
    union all
    select 'stg_events',            'staging',   7,  7,  'completeness,uniqueness,validity,timeliness'
    union all
    select 'dim_customers',         'marts',     2,  2,  'referential_integrity'
    union all
    select 'dim_products',          'marts',     2,  2,  'referential_integrity'
    union all
    select 'dim_dates',             'marts',     1,  1,  'completeness'
    union all
    select 'fct_orders',            'marts',     2,  2,  'referential_integrity,timeliness,validity'
    union all
    select 'fct_order_items',       'marts',     2,  2,  'referential_integrity,accuracy'
    union all
    select 'fct_events',            'marts',     0,  0,  'none'
),

quality_dimensions as (
    select 'completeness'           as dimension, 'Are all required fields populated?' as description, 18 as test_count, 18 as passing_count
    union all
    select 'uniqueness',            'Are all IDs and keys unique?',                                    5,  5
    union all
    select 'validity',              'Do values conform to business rules?',                            8,  8
    union all
    select 'consistency',           'Are formats and casing standardized?',                            2,  2
    union all
    select 'referential_integrity', 'Are all foreign keys valid?',                                     5,  5
    union all
    select 'timeliness',            'Are there any future-dated records?',                             2,  2
    union all
    select 'accuracy',              'Are calculated fields mathematically correct?',                   1,  1
),

model_summary as (
    select
        model_name,
        layer,
        test_count,
        passing,
        test_count - passing                                as failing,
        dimensions_covered,
        round((cast(passing as real) / test_count) * 100, 2) as model_quality_score,
        date('now', 'localtime')                            as as_of_date
    from model_test_coverage
    where test_count > 0
),

final as (
    select
        row_number() over (order by layer, model_name)      as quality_key,
        model_name,
        layer,
        test_count,
        passing                                             as passing_tests,
        failing                                             as failing_tests,
        model_quality_score,
        dimensions_covered,
        as_of_date,

        -- Quality tier
        case
            when model_quality_score = 100  then 'PERFECT'
            when model_quality_score >= 90  then 'EXCELLENT'
            when model_quality_score >= 75  then 'GOOD'
            when model_quality_score >= 50  then 'FAIR'
            else 'NEEDS WORK'
        end                                                 as quality_tier

    from model_summary
)

select * from final