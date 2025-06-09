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
