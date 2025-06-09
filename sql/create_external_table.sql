CREATE EXTERNAL TABLE default.acwr_metrics (
  player STRING,
  week DATE,
  match_minutes INT,
  sprints INT,
  distance DOUBLE,
  fatigue_score DOUBLE,
  injured_next_week BOOLEAN,
  acute_workload INT,
  chronic_workload DOUBLE,
  acwr DOUBLE,
  risk_flag STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "skip.header.line.count" = "1"
)
LOCATION 's3://injury-tracker-data/derived/acwr_metrics/';
