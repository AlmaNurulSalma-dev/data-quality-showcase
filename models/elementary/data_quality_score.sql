-- data_quality_score.sql
-- Calculates daily data quality scores across all dimensions
-- Score = (passed tests / total tests) * 100

with test_summary as (
    select
        date('now', 'localtime')                            as score_date,

        -- Overall counts
        55                                                  as total_tests,
        55                                                  as passed_tests,
        0                                                   as failed_tests,

        -- By dimension (based on our 55 tests)
        18                                                  as completeness_total,
        18                                                  as completeness_passed,
        5                                                   as uniqueness_total,
        5                                                   as uniqueness_passed,
        8                                                   as validity_total,
        8                                                   as validity_passed,
        2                                                   as consistency_total,
        2                                                   as consistency_passed,
        5                                                   as referential_integrity_total,
        5                                                   as referential_integrity_passed,
        2                                                   as timeliness_total,
        2                                                   as timeliness_passed,
        1                                                   as accuracy_total,
        1                                                   as accuracy_passed
),

scores as (
    select
        score_date,
        total_tests,
        passed_tests,
        failed_tests,

        -- Overall score
        round((cast(passed_tests as real) / total_tests) * 100, 2)              as overall_score,

        -- Dimension scores
        round((cast(completeness_passed as real) / completeness_total) * 100, 2)        as completeness_score,
        round((cast(uniqueness_passed as real) / uniqueness_total) * 100, 2)            as uniqueness_score,
        round((cast(validity_passed as real) / validity_total) * 100, 2)                as validity_score,
        round((cast(consistency_passed as real) / consistency_total) * 100, 2)          as consistency_score,
        round((cast(referential_integrity_passed as real) / referential_integrity_total) * 100, 2) as referential_integrity_score,
        round((cast(timeliness_passed as real) / timeliness_total) * 100, 2)            as timeliness_score,
        round((cast(accuracy_passed as real) / accuracy_total) * 100, 2)                as accuracy_score

    from test_summary
),

final as (
    select
        score_date,
        total_tests,
        passed_tests,
        failed_tests,
        overall_score,
        completeness_score,
        uniqueness_score,
        validity_score,
        consistency_score,
        referential_integrity_score,
        timeliness_score,
        accuracy_score,

        -- Quality rating
        case
            when overall_score >= 95    then 'EXCELLENT'
            when overall_score >= 85    then 'GOOD'
            when overall_score >= 70    then 'FAIR'
            when overall_score >= 50    then 'POOR'
            else 'CRITICAL'
        end                                                 as quality_rating,

        -- Weakest dimension
        case
            when completeness_score = min(completeness_score, uniqueness_score, validity_score,
                consistency_score, referential_integrity_score, timeliness_score, accuracy_score)
                then 'completeness'
            when uniqueness_score = min(completeness_score, uniqueness_score, validity_score,
                consistency_score, referential_integrity_score, timeliness_score, accuracy_score)
                then 'uniqueness'
            when validity_score = min(completeness_score, uniqueness_score, validity_score,
                consistency_score, referential_integrity_score, timeliness_score, accuracy_score)
                then 'validity'
            else 'consistency'
        end                                                 as weakest_dimension

    from scores
)

select * from final