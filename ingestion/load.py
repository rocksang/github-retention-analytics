import duckdb
import os

os.makedirs("data", exist_ok=True)

con = duckdb.connect("data/github.duckdb")

DATES_AND_HOURS = [
    ("2024-03-01", range(9, 12)),
    ("2024-03-08", range(9, 12)),
    ("2024-03-15", range(9, 12)),
]

urls = []
for date, hours in DATES_AND_HOURS:
    for hour in hours:
        urls.append(f"https://data.gharchive.org/{date}-{hour}.json.gz")

print(f"Streaming {len(urls)} files across 3 weeks...")
print("This will take 10-20 minutes — 72 files total...")

con.execute(f"""
    CREATE OR REPLACE TABLE raw_events AS
    SELECT
        id,
        type,
        actor.login     AS actor_login,
        actor.id        AS actor_id,
        repo.name       AS repo_name,
        repo.id         AS repo_id,
        created_at::TIMESTAMP AS created_at,
        public
    FROM read_ndjson(
        {urls},
        ignore_errors = true
    )
""")

count = con.execute("SELECT COUNT(*) FROM raw_events").fetchone()[0]
print(f"✅ Loaded {count:,} events into DuckDB")

print("\nTop event types:")
result = con.execute("""
    SELECT type, COUNT(*) AS count
    FROM raw_events
    GROUP BY type
    ORDER BY count DESC
    LIMIT 10
""").fetchall()

for row in result:
    print(f"  {row[0]:<30} {row[1]:>10,}")

con.close()
