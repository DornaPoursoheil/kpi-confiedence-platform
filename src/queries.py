from __future__ import annotations



KPI_HOURLY = """
select
  ts_utc,
  entity_type,
  entity_id,
  kpi_family,
  vehicle_class,
  value,
  confidence_score,
  confidence_label
from bi.vw_kpi_hourly_enriched
where year_utc = %(year)s
  and month_utc = %(month)s
  and entity_type = %(entity_type)s
"""


KPI_DAILY = """
select
  entity_type,
  entity_id,
  d_utc,
  year_utc,
  month_utc,
  day_utc,
  value_avg,
  confidence_score_avg,
  confidence_score_min,
  confidence_label_daily,
  kpi_family,
  vehicle_class,
  grain
from bi.vw_kpi_daily_enriched
"""

FILE_HISTORY = """
select
  run_id,
  source_url,
  month_key,
  dataset_version,
  source_type,
  decision,
  reason,
  rows_loaded,
  duration_ms,
  error_message,
  created_at
from ingestion.file_history
where created_at >= %(ts_from)s
order by created_at desc
limit %(limit)s
"""

KPI_DIAGNOSTICS = """
select
  ts_utc,
  entity_type,
  entity_id,
  kpi_family,
  vehicle_class,
  value,
  confidence_score,
  freshness_score,
  volume_score,
  null_score,
  anomaly_score,
  drift_score
from bi.vw_kpi_hourly_enriched
where year_utc = %(year)s
  and month_utc = %(month)s
  and entity_type = %(entity_type)s
"""

# Optional: missing_rate. If table is empty/not populated, UI will simply show "no data".
QA_MISSING = """
select
  det_id15 as entity_id,
  ts_utc,
  missing_rate,
  run_id
from analytics.qa_features_hourly
where ts_utc >= %(ts_from)s
  and ts_utc < %(ts_to)s
"""

# Optional: ML anomaly table. Used only if it exists & has rows.
ML_ANOMALY = """
select
  det_id15 as entity_id,
  ts_utc,
  model_name,
  anomaly_score,
  is_anomaly,
  top_driver,
  driver_value,
  run_id,
  created_at
from ml.ml_anomaly_score_hourly
where ts_utc >= %(ts_from)s
  and ts_utc < %(ts_to)s
"""
YEAR_MONTHS = """
select distinct
  year_utc,
  month_utc
from bi.vw_kpi_hourly_enriched
order by year_utc desc, month_utc desc
"""

DETECTOR_LIST = """
SELECT
    d.det_id15,
    s.strasse,
    s.richtung,
    s.position,
    d.spur,
    d.lon_wgs84,
    d.lat_wgs84
FROM bi.dim_detector d
LEFT JOIN staging.stg_stammdaten_verkehrsdetektion s
    ON d.det_id15 = s.det_id15
GROUP BY
    d.det_id15,
    s.strasse,
    s.richtung,
    s.position,
    d.spur,
    d.lon_wgs84,
    d.lat_wgs84
ORDER BY s.strasse, d.det_id15
"""
MISSING_RATE = """
select
  det_id15 as entity_id,
  ts_utc,
  missing_rate
from analytics.qa_features_hourly
where ts_utc >= %(ts_from)s
  and ts_utc < %(ts_to)s
"""
ANOMALY_OVERVIEW = """
select
  det_id15 as entity_id,
  ts_utc,
  anomaly_score,
  is_anomaly,
  top_driver,
  driver_value
from ml.ml_anomaly_score_hourly
where ts_utc >= %(ts_from)s
  and ts_utc < %(ts_to)s
"""


ANOMALY_BY_STREET = """
select
  s.strasse,
  count(*) filter (where a.is_anomaly) as anomaly_hours,
  count(*) as total_hours,
  count(*) filter (where a.is_anomaly)::float /
  count(*) as anomaly_rate
from ml.ml_anomaly_score_hourly a

join bi.dim_detector d
  on a.det_id15 = d.det_id15

left join staging.stg_stammdaten_verkehrsdetektion s
  on d.det_id15 = s.det_id15

where ts_utc >= %(ts_from)s
  and ts_utc < %(ts_to)s

group by s.strasse

order by anomaly_rate desc
"""
ANOMALY_BY_SENSOR = """
SELECT

    entity_id,

    SUM(is_anomaly) AS anomaly_hours,

    COUNT(*) AS total_hours,

    SUM(is_anomaly)::float / COUNT(*) AS anomaly_rate

FROM bi.vw_sensor_anomaly_hourly

WHERE
    ts_utc >= %(ts_from)s
    AND ts_utc < %(ts_to)s

GROUP BY
    entity_id

ORDER BY
    anomaly_rate DESC

LIMIT 20
"""