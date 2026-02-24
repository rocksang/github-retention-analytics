WITH user_stats AS (
    SELECT
        actor_id,
        actor_login,
        COUNT(*)                            AS total_events,
        COUNT(DISTINCT event_date)          AS active_days,

        COUNT(DISTINCT event_type)          AS breadth_of_actions,

        COUNT(DISTINCT repo_name)           AS repos_touched,
        MIN(created_at)                     AS first_seen_at,
        MAX(created_at)                     AS last_seen_at

    FROM {{ ref('stg_events') }}
    GROUP BY actor_id, actor_login
)

SELECT
    *,

    CASE
        WHEN active_days >= 5
         AND breadth_of_actions >= 3        THEN 'Power User'

        WHEN active_days >= 2
         AND total_events >= 10             THEN 'Engaged'

        WHEN active_days = 1
         AND total_events >= 3              THEN 'Casual'

        ELSE                                     'At Risk'
    END                                     AS engagement_segment

FROM user_stats