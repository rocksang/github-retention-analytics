SELECT
    e.actor_id,
    e.actor_login,
    e.event_date,

    COUNT(*)                                AS events_count,

    COUNT(DISTINCT e.event_type)            AS distinct_event_types,

    COUNT(DISTINCT e.repo_name)             AS repos_active_in

FROM {{ ref('stg_events') }} e
GROUP BY e.actor_id, e.actor_login, e.event_date