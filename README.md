## Dashboards (Metabase)
To view dashboards locally:
1. Ensure PostgreSQL is running with the `telco_churn` database populated
2. Run: `docker run -d -p 3000:3000 --name metabase metabase/metabase`
3. Open http://localhost:3000
4. Connect using Host: host.docker.internal, Port: 5432, DB: telco_churn
