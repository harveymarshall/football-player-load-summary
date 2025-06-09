CREATE TABLE IF NOT EXISTS gengarr.weekly_injury_summary
WITH (
  format = 'PARQUET',
  external_location = 's3://silver-hm/football-data/player-training-load/weekly-injury-summary'
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
