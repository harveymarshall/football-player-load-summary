### football-player-load-summary

# Summary

A project showcasing the ACWR metric to visualize player training load and injury summary.

In this Project I simulated 20 players training load over a number of weeks and used that simulated GPS data to calculate metrics used to create a Weekly Injury Report Dashboard as well as a Visual to monitor a players workload over time.

These visuals can be used to quickly demonstrate to players, coaches and trainers that particular players are close to injury or at risk of injury. While also being able to further use these metrics and data in Predictive Analytics to try prevent injury by identifying the precursors to injury through methods such as Machine Learning.

# Step-by-step

1. I firstly simulated the GPS data and uploaded the data as a CSV file to an S3 bucket. If I was to productionise this process I would build a pipeline to ingest the GPS data post training and matches to keep the raw dataset growing.
2. Then I used Athena SQL within AWS to create an external table over the raw dataset this made the raw GPS data queryable and I could build my metric tables off of it. The SQL query for this can be found in the file ./sql/create_external_table.sql
3. Now that I had a raw table with the GPS data in I could use it to build out other tables with metrics like ACWR.
4. I used this sql to create a

```sql
CREATE TABLE IF NOT EXISTS gengarr.acwr_metrics
WITH (
  format = 'PARQUET',
  external_location = 's3://silver-hm/football-data/player-training-load/acrw-metrics'
) AS
WITH workload_window AS (
  SELECT
    player,
    week,
    match_minutes,
    sprints,
    distance,
    fatigue_score,
    injured_next_week,
    match_minutes AS acute_workload,

    AVG(match_minutes) OVER (
      PARTITION BY player
      ORDER BY week
      ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS chronic_workload
  FROM player_load
)

SELECT *,
  ROUND(acute_workload / NULLIF(chronic_workload, 0), 2) AS acwr,
  CASE
    WHEN fatigue_score > 85 OR (acute_workload / NULLIF(chronic_workload, 0)) > 1.5
    THEN 'HIGH RISK'
    ELSE 'NORMAL'
  END AS risk_flag
FROM workload_window;
```

This SQL creates the ACWR metric using match minutes we use the current weeks match minutes as the acute_workload and use the current week pkus the 3 previous weeks average match minutes to create the chronic_workload metric.

5. Then using the fatigue_score and acute_worload / chronic_workload we set the risk_flag dependant on those two metrics.

6. Next step was to create another table holding the weekly_injury_summary. To do this I used this sql to create the table:

   ```sql
    CREATE TABLE IF NOT EXISTS gengarr.weekly_injury_summary
    WITH (
      format = 'PARQUET',
      external_location = 's3://silver-hm/football-data/player-training-load/   weekly-injury-summary'
    ) AS
    SELECT
      week,
      COUNT(*) AS total_players,
      SUM(CAST(injured_next_week AS INT)) AS injuries,
      ROUND(AVG(fatigue_score), 2) AS avg_fatigue,
      ROUND(AVG(match_minutes), 2) AS avg_minutes,
      ROUND(AVG(sprints), 2) AS avg_sprints
    FROM player_load
    GROUP BY week;
   ```

This table allows me to create visualisations for players, coaches andtrainers to consume allowing them to make decisions on how to best manageplayers or make team sheet decisions for upcoming games.

7. The next step now was to create our visualisations. I decided to do this with streamlit as I can version control the code and store it within this repository. Would I have productionised this project I would have the visulisation inside a tool like Tableau or PowerBI and connected directly to my source tables.

8.
