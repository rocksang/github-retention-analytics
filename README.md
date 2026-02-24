# GitHub Platform Retention Intelligence
> A PM-focused data engineering portfolio project

---

## Problem Statement

GitHub needs to understand which early user behaviors predict long-term platform retention, so the growth team can intervene at the right moment with the right nudge.

This project answers three core PM questions:
1. What % of new users reach the "activation" moment — pushing code?
2. Which behavioral segments exist, and how large is each?
3. Which cohorts retain best across weeks 1, 2, and 4?

---

## Key Findings

| Metric | Value |
|---|---|
| Total users observed | 144,261 |
| Activation rate (pushed code) | 60.5% |
| Largest segment | At Risk (93,965 users) |
| Second largest segment | Casual (50,315 users) |

**Top PM insights:**
- 60.5% of users pushed code — strong activation, but 39.5% never got past browsing
- The star → fork → push drop-off is the biggest conversion gap in the funnel
- Users who perform 3+ action types in their first session are disproportionately likely to become power users
- Week 2 is the critical retention window — re-engagement nudges at day 8-10 could recover lapsing users

---

## Target User

A Growth PM or Data PM at a developer-focused SaaS platform making decisions about:
- Onboarding flow improvements
- Re-engagement campaign targeting
- Feature prioritization based on activation signals

---

## Data Source

**GitHub Archive** (gharchive.org) — real public GitHub event stream. No signup required, completely free.

- 9 files across 3 weeks (2024-03-01, 2024-03-08, 2024-03-15)
- ~1.5 million real events from real GitHub users
- Event types: PushEvent, WatchEvent, ForkEvent, PullRequestEvent, IssuesEvent, CreateEvent

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Environment | GitHub Codespaces | Browser-based, no local setup |
| Data source | gharchive.org | Free, no account, streams directly |
| Warehouse | DuckDB | In-process, no server needed |
| Transform | dbt-core + dbt-duckdb | SQL-based modeling, free |
| Visualization | Jupyter + Plotly | Interactive charts, narrative format |
| Orchestration | GitHub Actions | Free, automated weekly refresh |

**Total cost: $0**

---

## Data Model

```
gharchive.org (raw JSON.gz)
       ↓
   raw_events (DuckDB table)
       ↓
   stg_events (staging — clean, filter bots)
       ↓
   int_user_first_actions     int_user_activity_daily
   (cohort assignment)        (daily activity per user)
       ↓                              ↓
   mart_retention_cohorts     mart_activation_funnel
   mart_engagement_segments
```

### dbt Models

| Model | Layer | Description |
|---|---|---|
| `stg_events` | Staging | Cleans raw events, filters bots, adds date dimensions |
| `int_user_first_actions` | Intermediate | First event per user — cohort assignment |
| `int_user_activity_daily` | Intermediate | Daily activity summary per user |
| `mart_retention_cohorts` | Mart | Cohort retention curves by week |
| `mart_activation_funnel` | Mart | Funnel conversion rates per action type |
| `mart_engagement_segments` | Mart | RFM-style user segmentation |

---

## How to Run

**Prerequisites:** GitHub Codespaces (free), no other accounts needed

```bash
# 1. Clone the repo and open in Codespaces
# 2. Install dependencies
pip install dbt-duckdb jupyter plotly pandas

# 3. Load data (streams directly from gharchive.org — no download)
python ingestion/load.py

# 4. Run dbt models
cd dbt_project && dbt run

# 5. Open the analysis notebook
cd ..
jupyter lab --no-browser --port=8888 --NotebookApp.token='' --NotebookApp.password=''
# Open port 8888 in Codespaces Ports tab
# Open analysis/github_retention_analysis.ipynb
```

---

## Limitations & Open Questions

- **Public events only** — private repo activity not captured, so active private contributors are undercounted
- **"First seen" ≠ true signup date** — users existed before our data window; first appearance is a proxy
- **Bot filtering is heuristic** — excludes `[bot]` and `-bot` usernames, but sophisticated bots may slip through
- **Sample window** — 3 hours per week × 3 weeks; a 30-day continuous window would produce more robust cohort curves
- **No demographic data** — can't segment by user type (student, professional, open source contributor)

**Open questions for a real PM team:**
- What does the activation funnel look like for users who signed up via GitHub Education vs organic?
- Do users who push to their own repos retain differently than those who contribute to others'?
- What is the relationship between repo stars received and long-term contributor retention?

---

## PM Value Demonstrated

| Skill | Where It Shows |
|---|---|
| Problem framing | This README — clear business question, target user, success metrics |
| Metric definition | Activation rate, cohort retention, RFM segmentation |
| Prioritization thinking | Key findings + recommendations in the notebook |
| Data literacy | dbt models with business logic explained in comments |
| Intellectual honesty | Limitations & open questions section |
| Technical credibility | Full working pipeline, zero paid tools |
| Stakeholder communication | Narrative notebook mixing analysis with PM commentary |

---

## Author

Built as a PM portfolio project demonstrating modern data stack skills applied to a real product analytics problem.