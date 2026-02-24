WITH cohorts AS (
    SELECT * FROM {{ ref('int_user_first_actions') }}
),

activity AS (
    SELECT * FROM {{ ref('int_user_activity_daily') }}
),

cohort_activity AS (
    SELECT
        c.cohort_week,
        c.actor_id,
        DATEDIFF('week', c.cohort_week, a.event_date) AS weeks_since_first
    FROM cohorts c
    JOIN activity a ON c.actor_id = a.actor_id
    WHERE a.event_date >= c.first_seen_at
),

cohort_sizes AS (
    SELECT cohort_week, COUNT(DISTINCT actor_id) AS cohort_size
    FROM cohorts
    GROUP BY cohort_week
)

SELECT
    ca.cohort_week,
    ca.weeks_since_first,
    COUNT(DISTINCT ca.actor_id)             AS retained_users,
    cs.cohort_size,

    ROUND(
        COUNT(DISTINCT ca.actor_id) * 100.0 / cs.cohort_size,
        1
    )                                       AS retention_pct

FROM cohort_activity ca
JOIN cohort_sizes cs ON ca.cohort_week = cs.cohort_week
GROUP BY ca.cohort_week, ca.weeks_since_first, cs.cohort_size
ORDER BY ca.cohort_week, ca.weeks_since_first