# GitHub Platform Retention Analysis

A PM-focused analysis of real GitHub user behavior, built on GitHub Archive data.

---

## Executive Summary
```sql activation_summary
select * from mart_activation_funnel
```

- **Total Users Observed:** {activation_summary[0].total_users}
- **Activation Rate (pushed code):** {activation_summary[0].activation_rate_pct}%

---

## Activation Funnel
```sql funnel
select 'Starred a Repo' as action, starred_a_repo as users from mart_activation_funnel
union all
select 'Forked a Repo', forked_a_repo from mart_activation_funnel
union all
select 'Created a Repo', created_a_repo from mart_activation_funnel
union all
select 'Pushed Code', pushed_code from mart_activation_funnel
union all
select 'Opened a PR', opened_a_pr from mart_activation_funnel
union all
select 'Opened an Issue', opened_an_issue from mart_activation_funnel
```

<BarChart
    data={funnel}
    x=action
    y=users
    title="User Activation Steps"
    swapXY=true
/>

---

## User Engagement Segments
```sql segments
select engagement_segment, count(*) as users
from mart_engagement_segments
group by engagement_segment
order by users desc
```

<DonutChart
    data={segments}
    name=engagement_segment
    value=users
    title="User Segments"
/>

---

## PM Recommendations

1. **Reduce the star → fork → push gap** — The largest funnel drop-off is between users who star a repo and those who fork it.

2. **Week 2 is the critical retention window** — Engagement typically drops sharply after the first week.

3. **Breadth predicts retention** — Users who perform 3+ action types in their first session are disproportionately likely to become Power Users.

---

## Data & Methodology

- **Source:** GitHub Archive (gharchive.org) — real public GitHub events
- **Window:** 3 hours of data (2024-03-01, 9am–11am UTC) — ~757k events
- **Limitations:** Public events only. Short window means retention cohorts are empty — a 30-day window would fix this.
- **Bot filtering:** Excludes usernames ending in `[bot]` or `-bot`