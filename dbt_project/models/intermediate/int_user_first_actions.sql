SELECT
    actor_id,
    actor_login,

    MIN(created_at)                         AS first_seen_at,

    DATE_TRUNC('week', MIN(created_at))     AS cohort_week,
    DATE_TRUNC('month', MIN(created_at))    AS cohort_month,

    FIRST(event_type ORDER BY created_at)   AS first_event_type

FROM {{ ref('stg_events') }}
GROUP BY actor_id, actor_login