WITH users AS (
    SELECT DISTINCT actor_id FROM {{ ref('stg_events') }}
),

event_counts AS (
    SELECT
        actor_id,
        COUNT_IF(event_type = 'PushEvent')          AS has_pushed,
        COUNT_IF(event_type = 'PullRequestEvent')   AS has_pr,
        COUNT_IF(event_type = 'WatchEvent')         AS has_starred,  -- WatchEvent = star
        COUNT_IF(event_type = 'ForkEvent')          AS has_forked,
        COUNT_IF(event_type = 'IssuesEvent')        AS has_opened_issue,
        COUNT_IF(event_type = 'CreateEvent')        AS has_created_repo
    FROM {{ ref('stg_events') }}
    GROUP BY actor_id
)

SELECT
    COUNT(DISTINCT u.actor_id)                      AS total_users,
    COUNT_IF(ec.has_starred > 0)                    AS starred_a_repo,
    COUNT_IF(ec.has_forked > 0)                     AS forked_a_repo,
    COUNT_IF(ec.has_pushed > 0)                     AS pushed_code,
    COUNT_IF(ec.has_created_repo > 0)               AS created_a_repo,
    COUNT_IF(ec.has_pr > 0)                         AS opened_a_pr,
    COUNT_IF(ec.has_opened_issue > 0)               AS opened_an_issue,

    ROUND(
        COUNT_IF(ec.has_pushed > 0) * 100.0 / COUNT(DISTINCT u.actor_id),
        1
    )                                               AS activation_rate_pct

FROM users u

LEFT JOIN event_counts ec ON u.actor_id = ec.actor_id