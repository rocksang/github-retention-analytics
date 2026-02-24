SELECT
    id                                      AS event_id,
    type                                    AS event_type,
    actor_login,
    actor_id,
    repo_name,
    repo_id,
    created_at,
    DATE_TRUNC('day', created_at)           AS event_date,
    DATE_TRUNC('week', created_at)          AS event_week,
    DATE_TRUNC('month', created_at)         AS event_month

FROM {{ source('main', 'raw_events') }}

WHERE actor_login IS NOT NULL
  AND created_at IS NOT NULL
  AND actor_login NOT LIKE '%[bot]%'
  AND actor_login NOT LIKE '%-bot'