--
-- PostgreSQL database dump
--

\restrict XfssvufVOfU3bXygO4UnjLSKWDCNgrGyo0fXgrA6NIM101aSp4ci3gIqMMaX6BK

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO postgres;

--
-- Name: bi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA bi;


ALTER SCHEMA bi OWNER TO postgres;

--
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- Name: ingestion; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ingestion;


ALTER SCHEMA ingestion OWNER TO postgres;

--
-- Name: kpi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA kpi;


ALTER SCHEMA kpi OWNER TO postgres;

--
-- Name: ml; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ml;


ALTER SCHEMA ml OWNER TO postgres;

--
-- Name: monitoring; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA monitoring;


ALTER SCHEMA monitoring OWNER TO postgres;

--
-- Name: raw; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA raw;


ALTER SCHEMA raw OWNER TO postgres;

--
-- Name: staging; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA staging;


ALTER SCHEMA staging OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: ensure_monthly_partitions(date); Type: FUNCTION; Schema: monitoring; Owner: postgres
--

CREATE FUNCTION monitoring.ensure_monthly_partitions(p_month date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  start_date    date := date_trunc('month', p_month)::date;end_date      date := (start_date + interval '1 month')::date;start_ts      timestamptz := (start_date::timestamp AT TIME ZONE 'UTC');end_ts        timestamptz := (end_date::timestamp   AT TIME ZONE 'UTC');suffix        text := to_char(start_date, 'YYYY_MM');parent        text;parent_schema text;parent_table  text;parent_qual   text;child_qual    text;BEGIN
    FOREACH parent IN ARRAY ARRAY[
    'core.fact_detector_hourly',
    'core.fact_mq_hourly',
    'core.fact_quality_hourly',
    'analytics.qa_features_hourly',
    'ml.ml_anomaly_score_hourly',
    'kpi.kpi_value',
    'kpi.kpi_confidence'
  ]
  LOOP
    parent_schema := split_part(parent, '.', 1);parent_table  := split_part(parent, '.', 2);parent_qual := format('%I.%I', parent_schema, parent_table);child_qual  := format('%I.%I', parent_schema, parent_table || '_' || suffix);IF to_regclass(child_qual) IS NULL THEN
      EXECUTE format(
        'CREATE TABLE %s PARTITION OF %s FOR VALUES FROM (%L) TO (%L);',
        child_qual, parent_qual, start_ts, end_ts
      );END IF;END LOOP;END;$$;


ALTER FUNCTION monitoring.ensure_monthly_partitions(p_month date) OWNER TO postgres;

SET default_tablespace = '';

--
-- Name: qa_features_hourly; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE analytics.qa_features_hourly OWNER TO postgres;

SET default_table_access_method = heap;

--
-- Name: qa_features_hourly_2023_03; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly_2023_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.qa_features_hourly_2023_03 OWNER TO postgres;

--
-- Name: qa_features_hourly_2024_03; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly_2024_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.qa_features_hourly_2024_03 OWNER TO postgres;

--
-- Name: qa_features_hourly_2024_04; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly_2024_04 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.qa_features_hourly_2024_04 OWNER TO postgres;

--
-- Name: qa_features_hourly_2025_01; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly_2025_01 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.qa_features_hourly_2025_01 OWNER TO postgres;

--
-- Name: qa_features_hourly_default; Type: TABLE; Schema: analytics; Owner: postgres
--

CREATE TABLE analytics.qa_features_hourly_default (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    row_count integer,
    missing_rate numeric(18,6),
    duplicate_rate numeric(18,6),
    freshness_lag_h integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.qa_features_hourly_default OWNER TO postgres;

--
-- Name: dim_detector; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.dim_detector (
    det_id15 bigint NOT NULL,
    mq_id15 bigint NOT NULL,
    det_name_alt text,
    det_name_neu text,
    spur text,
    annotation text,
    kommentar text,
    inbetriebnahme date,
    abbaudatum date,
    deinstalliert text,
    lon_wgs84 numeric(10,6),
    lat_wgs84 numeric(10,6)
);


ALTER TABLE core.dim_detector OWNER TO postgres;

--
-- Name: dim_detector; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.dim_detector AS
 SELECT det_id15,
    mq_id15,
    det_name_alt,
    det_name_neu,
    spur,
    annotation,
    kommentar,
    inbetriebnahme,
    abbaudatum,
    deinstalliert,
    lon_wgs84,
    lat_wgs84
   FROM core.dim_detector;


ALTER VIEW bi.dim_detector OWNER TO postgres;

--
-- Name: dim_mq; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.dim_mq (
    mq_id15 bigint NOT NULL,
    mq_kurzname text NOT NULL,
    strasse text,
    "position" text,
    pos_detail text,
    richtung text,
    lon_wgs84 numeric(10,6),
    lat_wgs84 numeric(10,6)
);


ALTER TABLE core.dim_mq OWNER TO postgres;

--
-- Name: dim_mq; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.dim_mq AS
 SELECT mq_id15,
    mq_kurzname,
    strasse,
    "position",
    pos_detail,
    richtung,
    lon_wgs84,
    lat_wgs84
   FROM core.dim_mq;


ALTER VIEW bi.dim_mq OWNER TO postgres;

--
-- Name: kpi_definition; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_definition (
    kpi_id integer NOT NULL,
    kpi_name text NOT NULL,
    description text,
    grain text NOT NULL,
    owner text,
    formula text,
    is_active boolean DEFAULT true NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE kpi.kpi_definition OWNER TO postgres;

--
-- Name: vw_kpi_definition; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_definition AS
 SELECT kpi_id,
        CASE
            WHEN (kpi_name ~~ 'flow\_%'::text) THEN regexp_replace(kpi_name, '^flow_'::text, 'volume_'::text)
            ELSE kpi_name
        END AS kpi_name,
    kpi_name AS kpi_name_raw
   FROM kpi.kpi_definition;


ALTER VIEW bi.vw_kpi_definition OWNER TO postgres;

--
-- Name: kpi_confidence; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE kpi.kpi_confidence OWNER TO postgres;

--
-- Name: vw_kpi_confidence_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_confidence_hourly AS
 SELECT kc.kpi_id,
    kd.kpi_name,
    kc.entity_type,
    kc.entity_id,
    kc.ts_utc,
    ((kc.ts_utc AT TIME ZONE 'UTC'::text))::date AS d_utc,
    (EXTRACT(year FROM (kc.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS year_utc,
    (EXTRACT(month FROM (kc.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS month_utc,
    (EXTRACT(day FROM (kc.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS day_utc,
    (EXTRACT(hour FROM (kc.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS hour_utc,
    kc.confidence_score,
    kc.confidence_label,
    kc.freshness_score,
    kc.volume_score,
    kc.null_score,
    kc.anomaly_score,
    kc.drift_score,
    kc.run_id,
    kc.calculated_at,
    kd.kpi_name_raw
   FROM (kpi.kpi_confidence kc
     LEFT JOIN bi.vw_kpi_definition kd ON ((kd.kpi_id = kc.kpi_id)));


ALTER VIEW bi.vw_kpi_confidence_hourly OWNER TO postgres;

--
-- Name: vw_kpi_confidence_hourly_enriched; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_confidence_hourly_enriched AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    confidence_score,
    confidence_label,
    freshness_score,
    volume_score,
    null_score,
    anomaly_score,
    drift_score,
    run_id,
    calculated_at,
    kpi_name_raw,
    split_part(kpi_name, '_'::text, 1) AS kpi_family,
    split_part(kpi_name, '_'::text, 2) AS vehicle_class,
    split_part(kpi_name, '_'::text, 3) AS grain
   FROM bi.vw_kpi_confidence_hourly c;


ALTER VIEW bi.vw_kpi_confidence_hourly_enriched OWNER TO postgres;

--
-- Name: kpi_confidence_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.kpi_confidence_hourly AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    confidence_score,
    confidence_label,
    freshness_score,
    volume_score,
    null_score,
    anomaly_score,
    drift_score,
    run_id,
    calculated_at,
    kpi_name_raw,
    kpi_family,
    vehicle_class,
    grain
   FROM bi.vw_kpi_confidence_hourly_enriched;


ALTER VIEW bi.kpi_confidence_hourly OWNER TO postgres;

--
-- Name: kpi_value; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE kpi.kpi_value OWNER TO postgres;

--
-- Name: vw_kpi_value_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_value_hourly AS
 SELECT kv.kpi_id,
    kd.kpi_name,
    kv.entity_type,
    kv.entity_id,
    kv.ts_utc,
    ((kv.ts_utc AT TIME ZONE 'UTC'::text))::date AS d_utc,
    (EXTRACT(year FROM (kv.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS year_utc,
    (EXTRACT(month FROM (kv.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS month_utc,
    (EXTRACT(day FROM (kv.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS day_utc,
    (EXTRACT(hour FROM (kv.ts_utc AT TIME ZONE 'UTC'::text)))::integer AS hour_utc,
    kv.value,
    kv.run_id,
    kv.calculated_at,
    kd.kpi_name_raw
   FROM (kpi.kpi_value kv
     LEFT JOIN bi.vw_kpi_definition kd ON ((kd.kpi_id = kv.kpi_id)));


ALTER VIEW bi.vw_kpi_value_hourly OWNER TO postgres;

--
-- Name: vw_kpi_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_hourly AS
 SELECT v.kpi_id,
    v.kpi_name,
    v.entity_type,
    v.entity_id,
    v.ts_utc,
    v.d_utc,
    v.year_utc,
    v.month_utc,
    v.day_utc,
    v.hour_utc,
    v.value,
    c.confidence_score,
    c.confidence_label,
    c.freshness_score,
    c.volume_score,
    c.null_score,
    c.anomaly_score,
    c.drift_score,
    v.run_id AS value_run_id,
    c.run_id AS confidence_run_id,
    v.calculated_at AS value_calculated_at,
    c.calculated_at AS confidence_calculated_at,
    v.kpi_name_raw
   FROM (bi.vw_kpi_value_hourly v
     LEFT JOIN bi.vw_kpi_confidence_hourly c ON (((c.kpi_id = v.kpi_id) AND (c.entity_type = v.entity_type) AND (c.entity_id = v.entity_id) AND (c.ts_utc = v.ts_utc))));


ALTER VIEW bi.vw_kpi_hourly OWNER TO postgres;

--
-- Name: vw_kpi_daily; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_daily AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    avg(value) AS value_avg,
    avg(confidence_score) AS confidence_score_avg,
    min(confidence_score) AS confidence_score_min,
        CASE
            WHEN (avg(confidence_score) >= 0.85) THEN 'high'::text
            WHEN (avg(confidence_score) >= 0.70) THEN 'medium'::text
            ELSE 'low'::text
        END AS confidence_label_daily
   FROM bi.vw_kpi_hourly
  GROUP BY kpi_id, kpi_name, entity_type, entity_id, d_utc, year_utc, month_utc, day_utc;


ALTER VIEW bi.vw_kpi_daily OWNER TO postgres;

--
-- Name: vw_kpi_daily_enriched; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_daily_enriched AS
 SELECT kpi_id,
    kpi_name,
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
    split_part(kpi_name, '_'::text, 1) AS kpi_family,
    split_part(kpi_name, '_'::text, 2) AS vehicle_class,
    split_part(kpi_name, '_'::text, 3) AS grain
   FROM bi.vw_kpi_daily d;


ALTER VIEW bi.vw_kpi_daily_enriched OWNER TO postgres;

--
-- Name: kpi_daily; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.kpi_daily AS
 SELECT kpi_id,
    kpi_name,
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
   FROM bi.vw_kpi_daily_enriched;


ALTER VIEW bi.kpi_daily OWNER TO postgres;

--
-- Name: vw_kpi_hourly_enriched; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_hourly_enriched AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    value,
    confidence_score,
    confidence_label,
    freshness_score,
    volume_score,
    null_score,
    anomaly_score,
    drift_score,
    value_run_id,
    confidence_run_id,
    value_calculated_at,
    confidence_calculated_at,
    kpi_name_raw,
    split_part(kpi_name, '_'::text, 1) AS kpi_family,
    split_part(kpi_name, '_'::text, 2) AS vehicle_class,
    split_part(kpi_name, '_'::text, 3) AS grain
   FROM bi.vw_kpi_hourly h;


ALTER VIEW bi.vw_kpi_hourly_enriched OWNER TO postgres;

--
-- Name: kpi_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.kpi_hourly AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    value,
    confidence_score,
    confidence_label,
    freshness_score,
    volume_score,
    null_score,
    anomaly_score,
    drift_score,
    value_run_id,
    confidence_run_id,
    value_calculated_at,
    confidence_calculated_at,
    kpi_name_raw,
    kpi_family,
    vehicle_class,
    grain
   FROM bi.vw_kpi_hourly_enriched;


ALTER VIEW bi.kpi_hourly OWNER TO postgres;

--
-- Name: vw_kpi_value_hourly_enriched; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_kpi_value_hourly_enriched AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    value,
    run_id,
    calculated_at,
    kpi_name_raw,
    split_part(kpi_name, '_'::text, 1) AS kpi_family,
    split_part(kpi_name, '_'::text, 2) AS vehicle_class,
    split_part(kpi_name, '_'::text, 3) AS grain
   FROM bi.vw_kpi_value_hourly v;


ALTER VIEW bi.vw_kpi_value_hourly_enriched OWNER TO postgres;

--
-- Name: kpi_value_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.kpi_value_hourly AS
 SELECT kpi_id,
    kpi_name,
    entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    value,
    run_id,
    calculated_at,
    kpi_name_raw,
    kpi_family,
    vehicle_class,
    grain
   FROM bi.vw_kpi_value_hourly_enriched;


ALTER VIEW bi.kpi_value_hourly OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE ml.ml_anomaly_score_hourly OWNER TO postgres;

--
-- Name: vw_sensor_anomaly_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_sensor_anomaly_hourly AS
 SELECT 'detector'::text AS entity_type,
    det_id15 AS entity_id,
    ts_utc,
    ((ts_utc AT TIME ZONE 'UTC'::text))::date AS d_utc,
    (EXTRACT(year FROM (ts_utc AT TIME ZONE 'UTC'::text)))::integer AS year_utc,
    (EXTRACT(month FROM (ts_utc AT TIME ZONE 'UTC'::text)))::integer AS month_utc,
    (EXTRACT(day FROM (ts_utc AT TIME ZONE 'UTC'::text)))::integer AS day_utc,
    (EXTRACT(hour FROM (ts_utc AT TIME ZONE 'UTC'::text)))::integer AS hour_utc,
    model_name,
    anomaly_score,
    is_anomaly,
    top_driver,
    driver_value,
    run_id,
    created_at
   FROM ml.ml_anomaly_score_hourly a;


ALTER VIEW bi.vw_sensor_anomaly_hourly OWNER TO postgres;

--
-- Name: vw_sensor_anomaly_daily; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_sensor_anomaly_daily AS
 SELECT entity_type,
    entity_id,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    avg((is_anomaly)::integer) AS anomaly_rate,
    (sum((is_anomaly)::integer))::integer AS anomaly_hours,
    max((is_anomaly)::integer) AS any_anomaly,
    avg(anomaly_score) AS anomaly_score_avg
   FROM bi.vw_sensor_anomaly_hourly
  GROUP BY entity_type, entity_id, d_utc, year_utc, month_utc, day_utc;


ALTER VIEW bi.vw_sensor_anomaly_daily OWNER TO postgres;

--
-- Name: sensor_anomaly_daily; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.sensor_anomaly_daily AS
 SELECT entity_type,
    entity_id,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    anomaly_rate,
    anomaly_hours,
    any_anomaly,
    anomaly_score_avg
   FROM bi.vw_sensor_anomaly_daily;


ALTER VIEW bi.sensor_anomaly_daily OWNER TO postgres;

--
-- Name: sensor_anomaly_hourly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.sensor_anomaly_hourly AS
 SELECT entity_type,
    entity_id,
    ts_utc,
    d_utc,
    year_utc,
    month_utc,
    day_utc,
    hour_utc,
    model_name,
    anomaly_score,
    is_anomaly,
    top_driver,
    driver_value,
    run_id,
    created_at
   FROM bi.vw_sensor_anomaly_hourly;


ALTER VIEW bi.sensor_anomaly_hourly OWNER TO postgres;

--
-- Name: ml_anomaly_monthly; Type: VIEW; Schema: ml; Owner: postgres
--

CREATE VIEW ml.ml_anomaly_monthly AS
 SELECT to_char(ts_utc, 'YYYY_MM'::text) AS month_key,
    det_id15,
    model_name,
    count(*) AS n_total,
    sum(
        CASE
            WHEN is_anomaly THEN 1
            ELSE 0
        END) AS n_anomaly,
    round(((sum(
        CASE
            WHEN is_anomaly THEN 1
            ELSE 0
        END))::numeric / (NULLIF(count(*), 0))::numeric), 6) AS anomaly_rate,
    sum(
        CASE
            WHEN (anomaly_score = (999)::numeric) THEN 1
            ELSE 0
        END) AS n_score_999,
    mode() WITHIN GROUP (ORDER BY top_driver) AS top_driver_mode,
    max(created_at) AS last_scored_at
   FROM ml.ml_anomaly_score_hourly s
  GROUP BY (to_char(ts_utc, 'YYYY_MM'::text)), det_id15, model_name;


ALTER VIEW ml.ml_anomaly_monthly OWNER TO postgres;

--
-- Name: vw_ml_anomaly_monthly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_ml_anomaly_monthly AS
 SELECT m.month_key,
    m.det_id15,
    m.model_name,
    m.n_total,
    m.n_anomaly,
    m.anomaly_rate,
    m.n_score_999,
    m.top_driver_mode,
    m.last_scored_at,
    d.det_name_alt
   FROM (ml.ml_anomaly_monthly m
     LEFT JOIN core.dim_detector d ON ((d.det_id15 = m.det_id15)));


ALTER VIEW bi.vw_ml_anomaly_monthly OWNER TO postgres;

--
-- Name: vw_ml_anomaly_summary_monthly; Type: VIEW; Schema: bi; Owner: postgres
--

CREATE VIEW bi.vw_ml_anomaly_summary_monthly AS
 SELECT month_key,
    model_name,
    count(DISTINCT det_id15) AS n_detectors,
    sum(n_total) AS n_total,
    sum(n_anomaly) AS n_anomaly,
    round((sum(n_anomaly) / NULLIF(sum(n_total), (0)::numeric)), 6) AS anomaly_rate,
    sum(n_score_999) AS n_score_999,
    max(last_scored_at) AS last_scored_at
   FROM ml.ml_anomaly_monthly
  GROUP BY month_key, model_name
  ORDER BY month_key, model_name;


ALTER VIEW bi.vw_ml_anomaly_summary_monthly OWNER TO postgres;

--
-- Name: dim_time_hour; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.dim_time_hour (
    ts_utc timestamp with time zone NOT NULL,
    date_local date,
    hour_local integer,
    month_local integer
);


ALTER TABLE core.dim_time_hour OWNER TO postgres;

--
-- Name: dim_vehicle_class; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.dim_vehicle_class (
    vehicle_class_id smallint NOT NULL,
    code text NOT NULL,
    label text
);


ALTER TABLE core.dim_vehicle_class OWNER TO postgres;

--
-- Name: fact_detector_hourly; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE core.fact_detector_hourly OWNER TO postgres;

--
-- Name: fact_detector_hourly_2023_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly_2023_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_detector_hourly_2023_03 OWNER TO postgres;

--
-- Name: fact_detector_hourly_2024_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly_2024_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_detector_hourly_2024_03 OWNER TO postgres;

--
-- Name: fact_detector_hourly_2024_04; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly_2024_04 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_detector_hourly_2024_04 OWNER TO postgres;

--
-- Name: fact_detector_hourly_2025_01; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly_2025_01 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_detector_hourly_2025_01 OWNER TO postgres;

--
-- Name: fact_detector_hourly_default; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_detector_hourly_default (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_detector_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_detector_hourly_default OWNER TO postgres;

--
-- Name: fact_mq_hourly; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE core.fact_mq_hourly OWNER TO postgres;

--
-- Name: fact_mq_hourly_2023_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly_2023_03 (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_mq_hourly_2023_03 OWNER TO postgres;

--
-- Name: fact_mq_hourly_2024_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly_2024_03 (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_mq_hourly_2024_03 OWNER TO postgres;

--
-- Name: fact_mq_hourly_2024_04; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly_2024_04 (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_mq_hourly_2024_04 OWNER TO postgres;

--
-- Name: fact_mq_hourly_2025_01; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly_2025_01 (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_mq_hourly_2025_01 OWNER TO postgres;

--
-- Name: fact_mq_hourly_default; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_mq_hourly_default (
    mq_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    vehicle_class_id smallint NOT NULL,
    flow_q integer,
    speed_v integer,
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_mq_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_mq_hourly_default OWNER TO postgres;

--
-- Name: fact_quality_hourly; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
)
PARTITION BY RANGE (ts_utc);


ALTER TABLE core.fact_quality_hourly OWNER TO postgres;

--
-- Name: fact_quality_hourly_2023_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly_2023_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_quality_hourly_2023_03 OWNER TO postgres;

--
-- Name: fact_quality_hourly_2024_03; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly_2024_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_quality_hourly_2024_03 OWNER TO postgres;

--
-- Name: fact_quality_hourly_2024_04; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly_2024_04 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_quality_hourly_2024_04 OWNER TO postgres;

--
-- Name: fact_quality_hourly_2025_01; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly_2025_01 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_quality_hourly_2025_01 OWNER TO postgres;

--
-- Name: fact_quality_hourly_default; Type: TABLE; Schema: core; Owner: postgres
--

CREATE TABLE core.fact_quality_hourly_default (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    quality_old numeric(12,6),
    completeness_new numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    source_layout text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT fact_quality_hourly_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text])))
);


ALTER TABLE core.fact_quality_hourly_default OWNER TO postgres;

--
-- Name: file_manifest; Type: TABLE; Schema: ingestion; Owner: postgres
--

CREATE TABLE ingestion.file_manifest (
    source_url text NOT NULL,
    dataset_version text NOT NULL,
    source_type text NOT NULL,
    month_key text NOT NULL,
    checksum_sha256 text NOT NULL,
    bytes bigint,
    last_modified timestamp with time zone,
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_ingested_at timestamp with time zone,
    last_ingestion_run_id uuid,
    last_status text DEFAULT 'unknown'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT chk_file_manifest_dataset_version CHECK ((dataset_version = ANY (ARRAY['old'::text, 'new'::text]))),
    CONSTRAINT chk_file_manifest_month_key CHECK ((month_key ~ '^[0-9]{4}_[0-9]{2}$'::text)),
    CONSTRAINT chk_file_manifest_source_type CHECK ((source_type = ANY (ARRAY['detectors'::text, 'cross_sections'::text])))
);


ALTER TABLE ingestion.file_manifest OWNER TO postgres;

--
-- Name: run_files; Type: TABLE; Schema: ingestion; Owner: postgres
--

CREATE TABLE ingestion.run_files (
    run_id uuid NOT NULL,
    source_url text NOT NULL,
    action text NOT NULL,
    row_count bigint,
    message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ingestion.run_files OWNER TO postgres;

--
-- Name: file_history; Type: VIEW; Schema: ingestion; Owner: postgres
--

CREATE VIEW ingestion.file_history AS
 SELECT rf.run_id,
    rf.source_url,
    fm.month_key,
    fm.dataset_version,
    rf.action AS decision,
    rf.message AS reason,
    rf.created_at AS "timestamp"
   FROM (ingestion.run_files rf
     LEFT JOIN ingestion.file_manifest fm ON ((fm.source_url = rf.source_url)));


ALTER VIEW ingestion.file_history OWNER TO postgres;

--
-- Name: ingestion_runs; Type: TABLE; Schema: ingestion; Owner: postgres
--

CREATE TABLE ingestion.ingestion_runs (
    run_id uuid DEFAULT gen_random_uuid() NOT NULL,
    triggered_by text NOT NULL,
    status text DEFAULT 'running'::text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    notes text,
    payload jsonb
);


ALTER TABLE ingestion.ingestion_runs OWNER TO postgres;

--
-- Name: kpi_confidence_2023_03; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence_2023_03 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_confidence_2023_03 OWNER TO postgres;

--
-- Name: kpi_confidence_2024_03; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence_2024_03 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_confidence_2024_03 OWNER TO postgres;

--
-- Name: kpi_confidence_2024_04; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence_2024_04 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_confidence_2024_04 OWNER TO postgres;

--
-- Name: kpi_confidence_2025_01; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence_2025_01 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_confidence_2025_01 OWNER TO postgres;

--
-- Name: kpi_confidence_default; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_confidence_default (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    confidence_score numeric(12,6),
    confidence_label text,
    freshness_score numeric(12,6),
    volume_score numeric(12,6),
    null_score numeric(12,6),
    anomaly_score numeric(12,6),
    drift_score numeric(12,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_conf_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_confidence_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_confidence_default OWNER TO postgres;

--
-- Name: kpi_definition_kpi_id_seq; Type: SEQUENCE; Schema: kpi; Owner: postgres
--

CREATE SEQUENCE kpi.kpi_definition_kpi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE kpi.kpi_definition_kpi_id_seq OWNER TO postgres;

--
-- Name: kpi_definition_kpi_id_seq; Type: SEQUENCE OWNED BY; Schema: kpi; Owner: postgres
--

ALTER SEQUENCE kpi.kpi_definition_kpi_id_seq OWNED BY kpi.kpi_definition.kpi_id;


--
-- Name: kpi_value_2023_03; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value_2023_03 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_value_2023_03 OWNER TO postgres;

--
-- Name: kpi_value_2024_03; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value_2024_03 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_value_2024_03 OWNER TO postgres;

--
-- Name: kpi_value_2024_04; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value_2024_04 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_value_2024_04 OWNER TO postgres;

--
-- Name: kpi_value_2025_01; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value_2025_01 (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_value_2025_01 OWNER TO postgres;

--
-- Name: kpi_value_default; Type: TABLE; Schema: kpi; Owner: postgres
--

CREATE TABLE kpi.kpi_value_default (
    kpi_id integer NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    entity_type text NOT NULL,
    entity_id bigint DEFAULT 0 NOT NULL,
    value numeric(18,6),
    run_id uuid NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_kpi_value_entity CHECK ((((entity_type = 'global'::text) AND (entity_id = 0)) OR ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text])) AND (entity_id > 0)))),
    CONSTRAINT kpi_value_entity_type_check CHECK ((entity_type = ANY (ARRAY['detector'::text, 'mq'::text, 'global'::text])))
);


ALTER TABLE kpi.kpi_value_default OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly_2023_03; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly_2023_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ml.ml_anomaly_score_hourly_2023_03 OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly_2024_03; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly_2024_03 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ml.ml_anomaly_score_hourly_2024_03 OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly_2024_04; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly_2024_04 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ml.ml_anomaly_score_hourly_2024_04 OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly_2025_01; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly_2025_01 (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ml.ml_anomaly_score_hourly_2025_01 OWNER TO postgres;

--
-- Name: ml_anomaly_score_hourly_default; Type: TABLE; Schema: ml; Owner: postgres
--

CREATE TABLE ml.ml_anomaly_score_hourly_default (
    det_id15 bigint NOT NULL,
    ts_utc timestamp with time zone NOT NULL,
    run_id uuid NOT NULL,
    model_name text NOT NULL,
    anomaly_score numeric(12,6) NOT NULL,
    is_anomaly boolean,
    top_driver text,
    driver_value numeric(12,6),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE ml.ml_anomaly_score_hourly_default OWNER TO postgres;

--
-- Name: pipeline_run; Type: TABLE; Schema: monitoring; Owner: postgres
--

CREATE TABLE monitoring.pipeline_run (
    run_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    status text DEFAULT 'running'::text NOT NULL,
    source_year integer,
    source_month integer,
    source_layout text,
    notes text,
    CONSTRAINT pipeline_run_source_layout_check CHECK ((source_layout = ANY (ARRAY['old'::text, 'new'::text, 'mixed'::text]))),
    CONSTRAINT pipeline_run_status_check CHECK ((status = ANY (ARRAY['running'::text, 'success'::text, 'failed'::text, 'partial'::text])))
);


ALTER TABLE monitoring.pipeline_run OWNER TO postgres;

--
-- Name: vw_default_partition_health; Type: VIEW; Schema: monitoring; Owner: postgres
--

CREATE VIEW monitoring.vw_default_partition_health AS
 SELECT now() AS checked_at,
    'core.fact_detector_hourly_default'::text AS partition_name,
    count(*) AS row_count
   FROM core.fact_detector_hourly_default
UNION ALL
 SELECT now() AS checked_at,
    'core.fact_mq_hourly_default'::text AS partition_name,
    count(*) AS row_count
   FROM core.fact_mq_hourly_default
UNION ALL
 SELECT now() AS checked_at,
    'core.fact_quality_hourly_default'::text AS partition_name,
    count(*) AS row_count
   FROM core.fact_quality_hourly_default
UNION ALL
 SELECT now() AS checked_at,
    'analytics.qa_features_hourly_default'::text AS partition_name,
    count(*) AS row_count
   FROM analytics.qa_features_hourly_default
UNION ALL
 SELECT now() AS checked_at,
    'ml.ml_anomaly_score_hourly_default'::text AS partition_name,
    count(*) AS row_count
   FROM ml.ml_anomaly_score_hourly_default
UNION ALL
 SELECT now() AS checked_at,
    'kpi.kpi_value_default'::text AS partition_name,
    count(*) AS row_count
   FROM kpi.kpi_value_default
UNION ALL
 SELECT now() AS checked_at,
    'kpi.kpi_confidence_default'::text AS partition_name,
    count(*) AS row_count
   FROM kpi.kpi_confidence_default;


ALTER VIEW monitoring.vw_default_partition_health OWNER TO postgres;

--
-- Name: traffic_rows; Type: TABLE; Schema: raw; Owner: postgres
--

CREATE TABLE raw.traffic_rows (
    id bigint NOT NULL,
    run_id uuid NOT NULL,
    source_url text NOT NULL,
    month_key text NOT NULL,
    dataset_version text NOT NULL,
    source_type text NOT NULL,
    row_number bigint NOT NULL,
    payload jsonb NOT NULL,
    loaded_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_raw_traffic_dataset_version CHECK ((dataset_version = ANY (ARRAY['old'::text, 'new'::text]))),
    CONSTRAINT chk_raw_traffic_month_key CHECK ((month_key ~ '^[0-9]{4}_[0-9]{2}$'::text)),
    CONSTRAINT chk_raw_traffic_source_type CHECK ((source_type = ANY (ARRAY['detectors'::text, 'cross_sections'::text])))
);


ALTER TABLE raw.traffic_rows OWNER TO postgres;

--
-- Name: traffic_rows_id_seq; Type: SEQUENCE; Schema: raw; Owner: postgres
--

CREATE SEQUENCE raw.traffic_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE raw.traffic_rows_id_seq OWNER TO postgres;

--
-- Name: traffic_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: raw; Owner: postgres
--

ALTER SEQUENCE raw.traffic_rows_id_seq OWNED BY raw.traffic_rows.id;


--
-- Name: stg_new_detector_hourly; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE UNLOGGED TABLE staging.stg_new_detector_hourly (
    det_name_alt text NOT NULL,
    det_index integer NOT NULL,
    datum_ortszeit date NOT NULL,
    stunde_ortszeit integer NOT NULL,
    vollstaendigkeit numeric(12,6),
    zscore_det0 numeric(12,6),
    zscore_det1 numeric(12,6),
    zscore_det2 numeric(12,6),
    hist_cor numeric(12,6),
    local_time timestamp with time zone,
    month integer,
    qkfz integer,
    qlkw integer,
    qpkw integer,
    utc timestamp with time zone,
    vkfz integer,
    vlkw integer,
    vpkw integer,
    source_file text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stg_new_detector_hourly_stunde_ortszeit_check CHECK (((stunde_ortszeit >= 0) AND (stunde_ortszeit <= 23)))
);


ALTER TABLE staging.stg_new_detector_hourly OWNER TO postgres;

--
-- Name: stg_old_det_val_hr; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE UNLOGGED TABLE staging.stg_old_det_val_hr (
    detid_15 bigint NOT NULL,
    tag date NOT NULL,
    stunde integer NOT NULL,
    qualitaet numeric(12,6),
    q_kfz_det_hr integer,
    v_kfz_det_hr integer,
    q_pkw_det_hr integer,
    v_pkw_det_hr integer,
    q_lkw_det_hr integer,
    v_lkw_det_hr integer,
    source_file text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stg_old_det_val_hr_stunde_check CHECK (((stunde >= 0) AND (stunde <= 23)))
);


ALTER TABLE staging.stg_old_det_val_hr OWNER TO postgres;

--
-- Name: stg_old_mq_hr; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE UNLOGGED TABLE staging.stg_old_mq_hr (
    mq_name text NOT NULL,
    tag date NOT NULL,
    stunde integer NOT NULL,
    qualitaet numeric(12,6),
    q_kfz_mq_hr integer,
    v_kfz_mq_hr integer,
    q_pkw_mq_hr integer,
    v_pkw_mq_hr integer,
    q_lkw_mq_hr integer,
    v_lkw_mq_hr integer,
    source_file text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stg_old_mq_hr_stunde_check CHECK (((stunde >= 0) AND (stunde <= 23)))
);


ALTER TABLE staging.stg_old_mq_hr OWNER TO postgres;

--
-- Name: stg_stammdaten_verkehrsdetektion; Type: TABLE; Schema: staging; Owner: postgres
--

CREATE TABLE staging.stg_stammdaten_verkehrsdetektion (
    mq_kurzname text,
    det_name_alt text,
    det_name_neu text,
    det_id15 bigint,
    mq_id15 bigint,
    strasse text,
    "position" text,
    pos_detail text,
    richtung text,
    spur text,
    annotation text,
    laenge_wgs84 numeric(10,6),
    breite_wgs84 numeric(10,6),
    inbetriebnahme date,
    abbaudatum date,
    deinstalliert text,
    kommentar text,
    source_file text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    snapshot_date date
);


ALTER TABLE staging.stg_stammdaten_verkehrsdetektion OWNER TO postgres;

--
-- Name: stg_stammdaten_detector; Type: VIEW; Schema: staging; Owner: postgres
--

CREATE VIEW staging.stg_stammdaten_detector AS
 SELECT DISTINCT ON (det_id15) det_id15,
    mq_id15,
    det_name_alt,
    det_name_neu,
    spur,
    annotation,
    kommentar,
    inbetriebnahme,
    abbaudatum,
    deinstalliert,
    laenge_wgs84 AS lon_wgs84,
    breite_wgs84 AS lat_wgs84,
    snapshot_date,
    source_file,
    ingested_at
   FROM staging.stg_stammdaten_verkehrsdetektion s
  WHERE (det_id15 IS NOT NULL)
  ORDER BY det_id15, snapshot_date DESC NULLS LAST, ingested_at DESC NULLS LAST, (mq_id15 IS NULL), det_name_alt;


ALTER VIEW staging.stg_stammdaten_detector OWNER TO postgres;

--
-- Name: stg_stammdaten_mq; Type: VIEW; Schema: staging; Owner: postgres
--

CREATE VIEW staging.stg_stammdaten_mq AS
 SELECT DISTINCT ON (mq_id15) mq_id15,
    mq_kurzname,
    strasse,
    "position",
    pos_detail,
    richtung,
    laenge_wgs84 AS lon_wgs84,
    breite_wgs84 AS lat_wgs84,
    snapshot_date,
    source_file,
    ingested_at
   FROM staging.stg_stammdaten_verkehrsdetektion s
  WHERE (mq_id15 IS NOT NULL)
  ORDER BY mq_id15, snapshot_date DESC NULLS LAST, ingested_at DESC NULLS LAST;


ALTER VIEW staging.stg_stammdaten_mq OWNER TO postgres;

--
-- Name: qa_features_hourly_2023_03; Type: TABLE ATTACH; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: qa_features_hourly_2024_03; Type: TABLE ATTACH; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: qa_features_hourly_2024_04; Type: TABLE ATTACH; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: qa_features_hourly_2025_01; Type: TABLE ATTACH; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: qa_features_hourly_default; Type: TABLE ATTACH; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_default DEFAULT;


--
-- Name: fact_detector_hourly_2023_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: fact_detector_hourly_2024_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: fact_detector_hourly_2024_04; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: fact_detector_hourly_2025_01; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: fact_detector_hourly_default; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_default DEFAULT;


--
-- Name: fact_mq_hourly_2023_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: fact_mq_hourly_2024_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: fact_mq_hourly_2024_04; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: fact_mq_hourly_2025_01; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: fact_mq_hourly_default; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_default DEFAULT;


--
-- Name: fact_quality_hourly_2023_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: fact_quality_hourly_2024_03; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: fact_quality_hourly_2024_04; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: fact_quality_hourly_2025_01; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: fact_quality_hourly_default; Type: TABLE ATTACH; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_default DEFAULT;


--
-- Name: kpi_confidence_2023_03; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: kpi_confidence_2024_03; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: kpi_confidence_2024_04; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: kpi_confidence_2025_01; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: kpi_confidence_default; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence ATTACH PARTITION kpi.kpi_confidence_default DEFAULT;


--
-- Name: kpi_value_2023_03; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value ATTACH PARTITION kpi.kpi_value_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: kpi_value_2024_03; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value ATTACH PARTITION kpi.kpi_value_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: kpi_value_2024_04; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value ATTACH PARTITION kpi.kpi_value_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: kpi_value_2025_01; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value ATTACH PARTITION kpi.kpi_value_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: kpi_value_default; Type: TABLE ATTACH; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value ATTACH PARTITION kpi.kpi_value_default DEFAULT;


--
-- Name: ml_anomaly_score_hourly_2023_03; Type: TABLE ATTACH; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2023_03 FOR VALUES FROM ('2023-03-01 01:00:00+01') TO ('2023-04-01 02:00:00+02');


--
-- Name: ml_anomaly_score_hourly_2024_03; Type: TABLE ATTACH; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_03 FOR VALUES FROM ('2024-03-01 01:00:00+01') TO ('2024-04-01 02:00:00+02');


--
-- Name: ml_anomaly_score_hourly_2024_04; Type: TABLE ATTACH; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_04 FOR VALUES FROM ('2024-04-01 02:00:00+02') TO ('2024-05-01 02:00:00+02');


--
-- Name: ml_anomaly_score_hourly_2025_01; Type: TABLE ATTACH; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2025_01 FOR VALUES FROM ('2025-01-01 01:00:00+01') TO ('2025-02-01 01:00:00+01');


--
-- Name: ml_anomaly_score_hourly_default; Type: TABLE ATTACH; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_default DEFAULT;


--
-- Name: kpi_definition kpi_id; Type: DEFAULT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_definition ALTER COLUMN kpi_id SET DEFAULT nextval('kpi.kpi_definition_kpi_id_seq'::regclass);


--
-- Name: traffic_rows id; Type: DEFAULT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.traffic_rows ALTER COLUMN id SET DEFAULT nextval('raw.traffic_rows_id_seq'::regclass);


--
-- Name: qa_features_hourly pk_qa_features_hourly; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly
    ADD CONSTRAINT pk_qa_features_hourly PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: qa_features_hourly_2023_03 qa_features_hourly_2023_03_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly_2023_03
    ADD CONSTRAINT qa_features_hourly_2023_03_pkey PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: qa_features_hourly_2024_03 qa_features_hourly_2024_03_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly_2024_03
    ADD CONSTRAINT qa_features_hourly_2024_03_pkey PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: qa_features_hourly_2024_04 qa_features_hourly_2024_04_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly_2024_04
    ADD CONSTRAINT qa_features_hourly_2024_04_pkey PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: qa_features_hourly_2025_01 qa_features_hourly_2025_01_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly_2025_01
    ADD CONSTRAINT qa_features_hourly_2025_01_pkey PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: qa_features_hourly_default qa_features_hourly_default_pkey; Type: CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE ONLY analytics.qa_features_hourly_default
    ADD CONSTRAINT qa_features_hourly_default_pkey PRIMARY KEY (det_id15, ts_utc, run_id);


--
-- Name: dim_detector dim_detector_det_name_alt_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_detector
    ADD CONSTRAINT dim_detector_det_name_alt_key UNIQUE (det_name_alt);


--
-- Name: dim_detector dim_detector_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_detector
    ADD CONSTRAINT dim_detector_pkey PRIMARY KEY (det_id15);


--
-- Name: dim_mq dim_mq_mq_kurzname_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_mq
    ADD CONSTRAINT dim_mq_mq_kurzname_key UNIQUE (mq_kurzname);


--
-- Name: dim_mq dim_mq_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_mq
    ADD CONSTRAINT dim_mq_pkey PRIMARY KEY (mq_id15);


--
-- Name: dim_time_hour dim_time_hour_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_time_hour
    ADD CONSTRAINT dim_time_hour_pkey PRIMARY KEY (ts_utc);


--
-- Name: dim_vehicle_class dim_vehicle_class_code_key; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_vehicle_class
    ADD CONSTRAINT dim_vehicle_class_code_key UNIQUE (code);


--
-- Name: dim_vehicle_class dim_vehicle_class_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_vehicle_class
    ADD CONSTRAINT dim_vehicle_class_pkey PRIMARY KEY (vehicle_class_id);


--
-- Name: fact_detector_hourly pk_fact_detector_hourly; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly
    ADD CONSTRAINT pk_fact_detector_hourly PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_detector_hourly_2023_03 fact_detector_hourly_2023_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly_2023_03
    ADD CONSTRAINT fact_detector_hourly_2023_03_pkey PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_detector_hourly_2024_03 fact_detector_hourly_2024_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly_2024_03
    ADD CONSTRAINT fact_detector_hourly_2024_03_pkey PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_detector_hourly_2024_04 fact_detector_hourly_2024_04_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly_2024_04
    ADD CONSTRAINT fact_detector_hourly_2024_04_pkey PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_detector_hourly_2025_01 fact_detector_hourly_2025_01_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly_2025_01
    ADD CONSTRAINT fact_detector_hourly_2025_01_pkey PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_detector_hourly_default fact_detector_hourly_default_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_detector_hourly_default
    ADD CONSTRAINT fact_detector_hourly_default_pkey PRIMARY KEY (det_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly pk_fact_mq_hourly; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly
    ADD CONSTRAINT pk_fact_mq_hourly PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly_2023_03 fact_mq_hourly_2023_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly_2023_03
    ADD CONSTRAINT fact_mq_hourly_2023_03_pkey PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly_2024_03 fact_mq_hourly_2024_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly_2024_03
    ADD CONSTRAINT fact_mq_hourly_2024_03_pkey PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly_2024_04 fact_mq_hourly_2024_04_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly_2024_04
    ADD CONSTRAINT fact_mq_hourly_2024_04_pkey PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly_2025_01 fact_mq_hourly_2025_01_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly_2025_01
    ADD CONSTRAINT fact_mq_hourly_2025_01_pkey PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_mq_hourly_default fact_mq_hourly_default_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_mq_hourly_default
    ADD CONSTRAINT fact_mq_hourly_default_pkey PRIMARY KEY (mq_id15, ts_utc, vehicle_class_id);


--
-- Name: fact_quality_hourly pk_fact_quality_hourly; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly
    ADD CONSTRAINT pk_fact_quality_hourly PRIMARY KEY (det_id15, ts_utc);


--
-- Name: fact_quality_hourly_2023_03 fact_quality_hourly_2023_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly_2023_03
    ADD CONSTRAINT fact_quality_hourly_2023_03_pkey PRIMARY KEY (det_id15, ts_utc);


--
-- Name: fact_quality_hourly_2024_03 fact_quality_hourly_2024_03_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly_2024_03
    ADD CONSTRAINT fact_quality_hourly_2024_03_pkey PRIMARY KEY (det_id15, ts_utc);


--
-- Name: fact_quality_hourly_2024_04 fact_quality_hourly_2024_04_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly_2024_04
    ADD CONSTRAINT fact_quality_hourly_2024_04_pkey PRIMARY KEY (det_id15, ts_utc);


--
-- Name: fact_quality_hourly_2025_01 fact_quality_hourly_2025_01_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly_2025_01
    ADD CONSTRAINT fact_quality_hourly_2025_01_pkey PRIMARY KEY (det_id15, ts_utc);


--
-- Name: fact_quality_hourly_default fact_quality_hourly_default_pkey; Type: CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.fact_quality_hourly_default
    ADD CONSTRAINT fact_quality_hourly_default_pkey PRIMARY KEY (det_id15, ts_utc);


--
-- Name: file_manifest file_manifest_pkey; Type: CONSTRAINT; Schema: ingestion; Owner: postgres
--

ALTER TABLE ONLY ingestion.file_manifest
    ADD CONSTRAINT file_manifest_pkey PRIMARY KEY (source_url);


--
-- Name: ingestion_runs ingestion_runs_pkey; Type: CONSTRAINT; Schema: ingestion; Owner: postgres
--

ALTER TABLE ONLY ingestion.ingestion_runs
    ADD CONSTRAINT ingestion_runs_pkey PRIMARY KEY (run_id);


--
-- Name: run_files run_files_pkey; Type: CONSTRAINT; Schema: ingestion; Owner: postgres
--

ALTER TABLE ONLY ingestion.run_files
    ADD CONSTRAINT run_files_pkey PRIMARY KEY (run_id, source_url);


--
-- Name: kpi_confidence pk_kpi_confidence; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence
    ADD CONSTRAINT pk_kpi_confidence PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_confidence_2023_03 kpi_confidence_2023_03_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence_2023_03
    ADD CONSTRAINT kpi_confidence_2023_03_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_confidence_2024_03 kpi_confidence_2024_03_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence_2024_03
    ADD CONSTRAINT kpi_confidence_2024_03_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_confidence_2024_04 kpi_confidence_2024_04_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence_2024_04
    ADD CONSTRAINT kpi_confidence_2024_04_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_confidence_2025_01 kpi_confidence_2025_01_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence_2025_01
    ADD CONSTRAINT kpi_confidence_2025_01_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_confidence_default kpi_confidence_default_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_confidence_default
    ADD CONSTRAINT kpi_confidence_default_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_definition kpi_definition_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_definition
    ADD CONSTRAINT kpi_definition_pkey PRIMARY KEY (kpi_id);


--
-- Name: kpi_value pk_kpi_value; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value
    ADD CONSTRAINT pk_kpi_value PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_value_2023_03 kpi_value_2023_03_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value_2023_03
    ADD CONSTRAINT kpi_value_2023_03_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_value_2024_03 kpi_value_2024_03_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value_2024_03
    ADD CONSTRAINT kpi_value_2024_03_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_value_2024_04 kpi_value_2024_04_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value_2024_04
    ADD CONSTRAINT kpi_value_2024_04_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_value_2025_01 kpi_value_2025_01_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value_2025_01
    ADD CONSTRAINT kpi_value_2025_01_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: kpi_value_default kpi_value_default_pkey; Type: CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE ONLY kpi.kpi_value_default
    ADD CONSTRAINT kpi_value_default_pkey PRIMARY KEY (kpi_id, ts_utc, entity_type, entity_id);


--
-- Name: ml_anomaly_score_hourly pk_ml_anomaly_score_hourly; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly
    ADD CONSTRAINT pk_ml_anomaly_score_hourly PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: ml_anomaly_score_hourly_2023_03 ml_anomaly_score_hourly_2023_03_pkey; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly_2023_03
    ADD CONSTRAINT ml_anomaly_score_hourly_2023_03_pkey PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: ml_anomaly_score_hourly_2024_03 ml_anomaly_score_hourly_2024_03_pkey; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly_2024_03
    ADD CONSTRAINT ml_anomaly_score_hourly_2024_03_pkey PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: ml_anomaly_score_hourly_2024_04 ml_anomaly_score_hourly_2024_04_pkey; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly_2024_04
    ADD CONSTRAINT ml_anomaly_score_hourly_2024_04_pkey PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: ml_anomaly_score_hourly_2025_01 ml_anomaly_score_hourly_2025_01_pkey; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly_2025_01
    ADD CONSTRAINT ml_anomaly_score_hourly_2025_01_pkey PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: ml_anomaly_score_hourly_default ml_anomaly_score_hourly_default_pkey; Type: CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ONLY ml.ml_anomaly_score_hourly_default
    ADD CONSTRAINT ml_anomaly_score_hourly_default_pkey PRIMARY KEY (det_id15, ts_utc, run_id, model_name);


--
-- Name: pipeline_run pipeline_run_pkey; Type: CONSTRAINT; Schema: monitoring; Owner: postgres
--

ALTER TABLE ONLY monitoring.pipeline_run
    ADD CONSTRAINT pipeline_run_pkey PRIMARY KEY (run_id);


--
-- Name: traffic_rows traffic_rows_pkey; Type: CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.traffic_rows
    ADD CONSTRAINT traffic_rows_pkey PRIMARY KEY (id);


--
-- Name: stg_new_detector_hourly pk_stg_new_detector_hourly; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.stg_new_detector_hourly
    ADD CONSTRAINT pk_stg_new_detector_hourly PRIMARY KEY (det_name_alt, det_index, datum_ortszeit, stunde_ortszeit);


--
-- Name: stg_old_det_val_hr pk_stg_old_det_val_hr; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.stg_old_det_val_hr
    ADD CONSTRAINT pk_stg_old_det_val_hr PRIMARY KEY (detid_15, tag, stunde);


--
-- Name: stg_old_mq_hr pk_stg_old_mq_hr; Type: CONSTRAINT; Schema: staging; Owner: postgres
--

ALTER TABLE ONLY staging.stg_old_mq_hr
    ADD CONSTRAINT pk_stg_old_mq_hr PRIMARY KEY (mq_name, tag, stunde);


--
-- Name: idx_qa_features_hourly_run; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX idx_qa_features_hourly_run ON ONLY analytics.qa_features_hourly USING btree (run_id);


--
-- Name: idx_qa_features_hourly_ts; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX idx_qa_features_hourly_ts ON ONLY analytics.qa_features_hourly USING btree (ts_utc);


--
-- Name: qa_features_hourly_2023_03_run_id_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2023_03_run_id_idx ON analytics.qa_features_hourly_2023_03 USING btree (run_id);


--
-- Name: qa_features_hourly_2023_03_ts_utc_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2023_03_ts_utc_idx ON analytics.qa_features_hourly_2023_03 USING btree (ts_utc);


--
-- Name: qa_features_hourly_2024_03_run_id_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2024_03_run_id_idx ON analytics.qa_features_hourly_2024_03 USING btree (run_id);


--
-- Name: qa_features_hourly_2024_03_ts_utc_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2024_03_ts_utc_idx ON analytics.qa_features_hourly_2024_03 USING btree (ts_utc);


--
-- Name: qa_features_hourly_2024_04_run_id_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2024_04_run_id_idx ON analytics.qa_features_hourly_2024_04 USING btree (run_id);


--
-- Name: qa_features_hourly_2024_04_ts_utc_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2024_04_ts_utc_idx ON analytics.qa_features_hourly_2024_04 USING btree (ts_utc);


--
-- Name: qa_features_hourly_2025_01_run_id_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2025_01_run_id_idx ON analytics.qa_features_hourly_2025_01 USING btree (run_id);


--
-- Name: qa_features_hourly_2025_01_ts_utc_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_2025_01_ts_utc_idx ON analytics.qa_features_hourly_2025_01 USING btree (ts_utc);


--
-- Name: qa_features_hourly_default_run_id_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_default_run_id_idx ON analytics.qa_features_hourly_default USING btree (run_id);


--
-- Name: qa_features_hourly_default_ts_utc_idx; Type: INDEX; Schema: analytics; Owner: postgres
--

CREATE INDEX qa_features_hourly_default_ts_utc_idx ON analytics.qa_features_hourly_default USING btree (ts_utc);


--
-- Name: idx_fact_detector_hourly_ts; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_fact_detector_hourly_ts ON ONLY core.fact_detector_hourly USING btree (ts_utc);


--
-- Name: fact_detector_hourly_2023_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_detector_hourly_2023_03_ts_utc_idx ON core.fact_detector_hourly_2023_03 USING btree (ts_utc);


--
-- Name: fact_detector_hourly_2024_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_detector_hourly_2024_03_ts_utc_idx ON core.fact_detector_hourly_2024_03 USING btree (ts_utc);


--
-- Name: fact_detector_hourly_2024_04_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_detector_hourly_2024_04_ts_utc_idx ON core.fact_detector_hourly_2024_04 USING btree (ts_utc);


--
-- Name: fact_detector_hourly_2025_01_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_detector_hourly_2025_01_ts_utc_idx ON core.fact_detector_hourly_2025_01 USING btree (ts_utc);


--
-- Name: fact_detector_hourly_default_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_detector_hourly_default_ts_utc_idx ON core.fact_detector_hourly_default USING btree (ts_utc);


--
-- Name: idx_fact_mq_hourly_ts; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_fact_mq_hourly_ts ON ONLY core.fact_mq_hourly USING btree (ts_utc);


--
-- Name: fact_mq_hourly_2023_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_mq_hourly_2023_03_ts_utc_idx ON core.fact_mq_hourly_2023_03 USING btree (ts_utc);


--
-- Name: fact_mq_hourly_2024_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_mq_hourly_2024_03_ts_utc_idx ON core.fact_mq_hourly_2024_03 USING btree (ts_utc);


--
-- Name: fact_mq_hourly_2024_04_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_mq_hourly_2024_04_ts_utc_idx ON core.fact_mq_hourly_2024_04 USING btree (ts_utc);


--
-- Name: fact_mq_hourly_2025_01_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_mq_hourly_2025_01_ts_utc_idx ON core.fact_mq_hourly_2025_01 USING btree (ts_utc);


--
-- Name: fact_mq_hourly_default_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_mq_hourly_default_ts_utc_idx ON core.fact_mq_hourly_default USING btree (ts_utc);


--
-- Name: idx_fact_quality_hourly_ts; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_fact_quality_hourly_ts ON ONLY core.fact_quality_hourly USING btree (ts_utc);


--
-- Name: fact_quality_hourly_2023_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_quality_hourly_2023_03_ts_utc_idx ON core.fact_quality_hourly_2023_03 USING btree (ts_utc);


--
-- Name: fact_quality_hourly_2024_03_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_quality_hourly_2024_03_ts_utc_idx ON core.fact_quality_hourly_2024_03 USING btree (ts_utc);


--
-- Name: fact_quality_hourly_2024_04_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_quality_hourly_2024_04_ts_utc_idx ON core.fact_quality_hourly_2024_04 USING btree (ts_utc);


--
-- Name: fact_quality_hourly_2025_01_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_quality_hourly_2025_01_ts_utc_idx ON core.fact_quality_hourly_2025_01 USING btree (ts_utc);


--
-- Name: fact_quality_hourly_default_ts_utc_idx; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX fact_quality_hourly_default_ts_utc_idx ON core.fact_quality_hourly_default USING btree (ts_utc);


--
-- Name: idx_dim_detector_mq; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_dim_detector_mq ON core.dim_detector USING btree (mq_id15);


--
-- Name: idx_dim_detector_name_alt; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX idx_dim_detector_name_alt ON core.dim_detector USING btree (det_name_alt);


--
-- Name: ix_dim_vehicle_class_code; Type: INDEX; Schema: core; Owner: postgres
--

CREATE INDEX ix_dim_vehicle_class_code ON core.dim_vehicle_class USING btree (code);


--
-- Name: idx_file_manifest_last_seen; Type: INDEX; Schema: ingestion; Owner: postgres
--

CREATE INDEX idx_file_manifest_last_seen ON ingestion.file_manifest USING btree (last_seen_at DESC);


--
-- Name: idx_file_manifest_month; Type: INDEX; Schema: ingestion; Owner: postgres
--

CREATE INDEX idx_file_manifest_month ON ingestion.file_manifest USING btree (month_key, dataset_version, source_type);


--
-- Name: idx_ingestion_runs_started_at; Type: INDEX; Schema: ingestion; Owner: postgres
--

CREATE INDEX idx_ingestion_runs_started_at ON ingestion.ingestion_runs USING btree (started_at DESC);


--
-- Name: idx_run_files_created_at; Type: INDEX; Schema: ingestion; Owner: postgres
--

CREATE INDEX idx_run_files_created_at ON ingestion.run_files USING btree (created_at DESC);


--
-- Name: idx_kpi_conf_entity_ts; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_conf_entity_ts ON ONLY kpi.kpi_confidence USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: idx_kpi_conf_run; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_conf_run ON ONLY kpi.kpi_confidence USING btree (run_id);


--
-- Name: idx_kpi_conf_ts; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_conf_ts ON ONLY kpi.kpi_confidence USING btree (ts_utc);


--
-- Name: idx_kpi_value_entity_ts; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_value_entity_ts ON ONLY kpi.kpi_value USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: idx_kpi_value_run; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_value_run ON ONLY kpi.kpi_value USING btree (run_id);


--
-- Name: idx_kpi_value_ts; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX idx_kpi_value_ts ON ONLY kpi.kpi_value USING btree (ts_utc);


--
-- Name: kpi_confidence_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_confidence_2023_03 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_confidence_2023_03_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2023_03_run_id_idx ON kpi.kpi_confidence_2023_03 USING btree (run_id);


--
-- Name: kpi_confidence_2023_03_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2023_03_ts_utc_idx ON kpi.kpi_confidence_2023_03 USING btree (ts_utc);


--
-- Name: kpi_confidence_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_confidence_2024_03 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_confidence_2024_03_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_03_run_id_idx ON kpi.kpi_confidence_2024_03 USING btree (run_id);


--
-- Name: kpi_confidence_2024_03_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_03_ts_utc_idx ON kpi.kpi_confidence_2024_03 USING btree (ts_utc);


--
-- Name: kpi_confidence_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_confidence_2024_04 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_confidence_2024_04_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_04_run_id_idx ON kpi.kpi_confidence_2024_04 USING btree (run_id);


--
-- Name: kpi_confidence_2024_04_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2024_04_ts_utc_idx ON kpi.kpi_confidence_2024_04 USING btree (ts_utc);


--
-- Name: kpi_confidence_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_confidence_2025_01 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_confidence_2025_01_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2025_01_run_id_idx ON kpi.kpi_confidence_2025_01 USING btree (run_id);


--
-- Name: kpi_confidence_2025_01_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_2025_01_ts_utc_idx ON kpi.kpi_confidence_2025_01 USING btree (ts_utc);


--
-- Name: kpi_confidence_default_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_default_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_confidence_default USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_confidence_default_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_default_run_id_idx ON kpi.kpi_confidence_default USING btree (run_id);


--
-- Name: kpi_confidence_default_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_confidence_default_ts_utc_idx ON kpi.kpi_confidence_default USING btree (ts_utc);


--
-- Name: kpi_value_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_value_2023_03 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_value_2023_03_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2023_03_run_id_idx ON kpi.kpi_value_2023_03 USING btree (run_id);


--
-- Name: kpi_value_2023_03_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2023_03_ts_utc_idx ON kpi.kpi_value_2023_03 USING btree (ts_utc);


--
-- Name: kpi_value_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_value_2024_03 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_value_2024_03_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_03_run_id_idx ON kpi.kpi_value_2024_03 USING btree (run_id);


--
-- Name: kpi_value_2024_03_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_03_ts_utc_idx ON kpi.kpi_value_2024_03 USING btree (ts_utc);


--
-- Name: kpi_value_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_value_2024_04 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_value_2024_04_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_04_run_id_idx ON kpi.kpi_value_2024_04 USING btree (run_id);


--
-- Name: kpi_value_2024_04_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2024_04_ts_utc_idx ON kpi.kpi_value_2024_04 USING btree (ts_utc);


--
-- Name: kpi_value_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_value_2025_01 USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_value_2025_01_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2025_01_run_id_idx ON kpi.kpi_value_2025_01 USING btree (run_id);


--
-- Name: kpi_value_2025_01_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_2025_01_ts_utc_idx ON kpi.kpi_value_2025_01 USING btree (ts_utc);


--
-- Name: kpi_value_default_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_default_entity_type_entity_id_ts_utc_kpi_id_idx ON kpi.kpi_value_default USING btree (entity_type, entity_id, ts_utc, kpi_id);


--
-- Name: kpi_value_default_run_id_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_default_run_id_idx ON kpi.kpi_value_default USING btree (run_id);


--
-- Name: kpi_value_default_ts_utc_idx; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE INDEX kpi_value_default_ts_utc_idx ON kpi.kpi_value_default USING btree (ts_utc);


--
-- Name: uq_kpi_definition_name; Type: INDEX; Schema: kpi; Owner: postgres
--

CREATE UNIQUE INDEX uq_kpi_definition_name ON kpi.kpi_definition USING btree (kpi_name);


--
-- Name: idx_ml_anomaly_score_hourly_run; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX idx_ml_anomaly_score_hourly_run ON ONLY ml.ml_anomaly_score_hourly USING btree (run_id);


--
-- Name: idx_ml_anomaly_score_hourly_ts; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX idx_ml_anomaly_score_hourly_ts ON ONLY ml.ml_anomaly_score_hourly USING btree (ts_utc);


--
-- Name: ml_anomaly_score_hourly_2023_03_run_id_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2023_03_run_id_idx ON ml.ml_anomaly_score_hourly_2023_03 USING btree (run_id);


--
-- Name: ml_anomaly_score_hourly_2023_03_ts_utc_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2023_03_ts_utc_idx ON ml.ml_anomaly_score_hourly_2023_03 USING btree (ts_utc);


--
-- Name: ml_anomaly_score_hourly_2024_03_run_id_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2024_03_run_id_idx ON ml.ml_anomaly_score_hourly_2024_03 USING btree (run_id);


--
-- Name: ml_anomaly_score_hourly_2024_03_ts_utc_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2024_03_ts_utc_idx ON ml.ml_anomaly_score_hourly_2024_03 USING btree (ts_utc);


--
-- Name: ml_anomaly_score_hourly_2024_04_run_id_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2024_04_run_id_idx ON ml.ml_anomaly_score_hourly_2024_04 USING btree (run_id);


--
-- Name: ml_anomaly_score_hourly_2024_04_ts_utc_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2024_04_ts_utc_idx ON ml.ml_anomaly_score_hourly_2024_04 USING btree (ts_utc);


--
-- Name: ml_anomaly_score_hourly_2025_01_run_id_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2025_01_run_id_idx ON ml.ml_anomaly_score_hourly_2025_01 USING btree (run_id);


--
-- Name: ml_anomaly_score_hourly_2025_01_ts_utc_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_2025_01_ts_utc_idx ON ml.ml_anomaly_score_hourly_2025_01 USING btree (ts_utc);


--
-- Name: ml_anomaly_score_hourly_default_run_id_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_default_run_id_idx ON ml.ml_anomaly_score_hourly_default USING btree (run_id);


--
-- Name: ml_anomaly_score_hourly_default_ts_utc_idx; Type: INDEX; Schema: ml; Owner: postgres
--

CREATE INDEX ml_anomaly_score_hourly_default_ts_utc_idx ON ml.ml_anomaly_score_hourly_default USING btree (ts_utc);


--
-- Name: idx_pipeline_run_started_at; Type: INDEX; Schema: monitoring; Owner: postgres
--

CREATE INDEX idx_pipeline_run_started_at ON monitoring.pipeline_run USING btree (started_at);


--
-- Name: idx_raw_traffic_month; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_raw_traffic_month ON raw.traffic_rows USING btree (month_key, dataset_version, source_type);


--
-- Name: idx_raw_traffic_run_id; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_raw_traffic_run_id ON raw.traffic_rows USING btree (run_id);


--
-- Name: idx_raw_traffic_source_url; Type: INDEX; Schema: raw; Owner: postgres
--

CREATE INDEX idx_raw_traffic_source_url ON raw.traffic_rows USING btree (source_url);


--
-- Name: idx_stg_new_detector_hourly_utc; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_new_detector_hourly_utc ON staging.stg_new_detector_hourly USING btree (utc);


--
-- Name: idx_stg_old_det_val_hr_tag; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_old_det_val_hr_tag ON staging.stg_old_det_val_hr USING btree (tag);


--
-- Name: idx_stg_old_mq_hr_tag; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_old_mq_hr_tag ON staging.stg_old_mq_hr USING btree (tag);


--
-- Name: idx_stg_stammdaten_det_id15; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_stammdaten_det_id15 ON staging.stg_stammdaten_verkehrsdetektion USING btree (det_id15);


--
-- Name: idx_stg_stammdaten_mq_id15; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_stammdaten_mq_id15 ON staging.stg_stammdaten_verkehrsdetektion USING btree (mq_id15);


--
-- Name: idx_stg_stammdaten_snapshot_date; Type: INDEX; Schema: staging; Owner: postgres
--

CREATE INDEX idx_stg_stammdaten_snapshot_date ON staging.stg_stammdaten_verkehrsdetektion USING btree (snapshot_date);


--
-- Name: qa_features_hourly_2023_03_pkey; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.pk_qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2023_03_pkey;


--
-- Name: qa_features_hourly_2023_03_run_id_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_run ATTACH PARTITION analytics.qa_features_hourly_2023_03_run_id_idx;


--
-- Name: qa_features_hourly_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_ts ATTACH PARTITION analytics.qa_features_hourly_2023_03_ts_utc_idx;


--
-- Name: qa_features_hourly_2024_03_pkey; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.pk_qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2024_03_pkey;


--
-- Name: qa_features_hourly_2024_03_run_id_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_run ATTACH PARTITION analytics.qa_features_hourly_2024_03_run_id_idx;


--
-- Name: qa_features_hourly_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_ts ATTACH PARTITION analytics.qa_features_hourly_2024_03_ts_utc_idx;


--
-- Name: qa_features_hourly_2024_04_pkey; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.pk_qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2024_04_pkey;


--
-- Name: qa_features_hourly_2024_04_run_id_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_run ATTACH PARTITION analytics.qa_features_hourly_2024_04_run_id_idx;


--
-- Name: qa_features_hourly_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_ts ATTACH PARTITION analytics.qa_features_hourly_2024_04_ts_utc_idx;


--
-- Name: qa_features_hourly_2025_01_pkey; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.pk_qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_2025_01_pkey;


--
-- Name: qa_features_hourly_2025_01_run_id_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_run ATTACH PARTITION analytics.qa_features_hourly_2025_01_run_id_idx;


--
-- Name: qa_features_hourly_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_ts ATTACH PARTITION analytics.qa_features_hourly_2025_01_ts_utc_idx;


--
-- Name: qa_features_hourly_default_pkey; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.pk_qa_features_hourly ATTACH PARTITION analytics.qa_features_hourly_default_pkey;


--
-- Name: qa_features_hourly_default_run_id_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_run ATTACH PARTITION analytics.qa_features_hourly_default_run_id_idx;


--
-- Name: qa_features_hourly_default_ts_utc_idx; Type: INDEX ATTACH; Schema: analytics; Owner: postgres
--

ALTER INDEX analytics.idx_qa_features_hourly_ts ATTACH PARTITION analytics.qa_features_hourly_default_ts_utc_idx;


--
-- Name: fact_detector_hourly_2023_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2023_03_pkey;


--
-- Name: fact_detector_hourly_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_detector_hourly_ts ATTACH PARTITION core.fact_detector_hourly_2023_03_ts_utc_idx;


--
-- Name: fact_detector_hourly_2024_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2024_03_pkey;


--
-- Name: fact_detector_hourly_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_detector_hourly_ts ATTACH PARTITION core.fact_detector_hourly_2024_03_ts_utc_idx;


--
-- Name: fact_detector_hourly_2024_04_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2024_04_pkey;


--
-- Name: fact_detector_hourly_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_detector_hourly_ts ATTACH PARTITION core.fact_detector_hourly_2024_04_ts_utc_idx;


--
-- Name: fact_detector_hourly_2025_01_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_2025_01_pkey;


--
-- Name: fact_detector_hourly_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_detector_hourly_ts ATTACH PARTITION core.fact_detector_hourly_2025_01_ts_utc_idx;


--
-- Name: fact_detector_hourly_default_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_detector_hourly ATTACH PARTITION core.fact_detector_hourly_default_pkey;


--
-- Name: fact_detector_hourly_default_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_detector_hourly_ts ATTACH PARTITION core.fact_detector_hourly_default_ts_utc_idx;


--
-- Name: fact_mq_hourly_2023_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2023_03_pkey;


--
-- Name: fact_mq_hourly_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_mq_hourly_ts ATTACH PARTITION core.fact_mq_hourly_2023_03_ts_utc_idx;


--
-- Name: fact_mq_hourly_2024_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2024_03_pkey;


--
-- Name: fact_mq_hourly_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_mq_hourly_ts ATTACH PARTITION core.fact_mq_hourly_2024_03_ts_utc_idx;


--
-- Name: fact_mq_hourly_2024_04_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2024_04_pkey;


--
-- Name: fact_mq_hourly_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_mq_hourly_ts ATTACH PARTITION core.fact_mq_hourly_2024_04_ts_utc_idx;


--
-- Name: fact_mq_hourly_2025_01_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_2025_01_pkey;


--
-- Name: fact_mq_hourly_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_mq_hourly_ts ATTACH PARTITION core.fact_mq_hourly_2025_01_ts_utc_idx;


--
-- Name: fact_mq_hourly_default_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_mq_hourly ATTACH PARTITION core.fact_mq_hourly_default_pkey;


--
-- Name: fact_mq_hourly_default_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_mq_hourly_ts ATTACH PARTITION core.fact_mq_hourly_default_ts_utc_idx;


--
-- Name: fact_quality_hourly_2023_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2023_03_pkey;


--
-- Name: fact_quality_hourly_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_quality_hourly_ts ATTACH PARTITION core.fact_quality_hourly_2023_03_ts_utc_idx;


--
-- Name: fact_quality_hourly_2024_03_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2024_03_pkey;


--
-- Name: fact_quality_hourly_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_quality_hourly_ts ATTACH PARTITION core.fact_quality_hourly_2024_03_ts_utc_idx;


--
-- Name: fact_quality_hourly_2024_04_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2024_04_pkey;


--
-- Name: fact_quality_hourly_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_quality_hourly_ts ATTACH PARTITION core.fact_quality_hourly_2024_04_ts_utc_idx;


--
-- Name: fact_quality_hourly_2025_01_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_2025_01_pkey;


--
-- Name: fact_quality_hourly_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_quality_hourly_ts ATTACH PARTITION core.fact_quality_hourly_2025_01_ts_utc_idx;


--
-- Name: fact_quality_hourly_default_pkey; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.pk_fact_quality_hourly ATTACH PARTITION core.fact_quality_hourly_default_pkey;


--
-- Name: fact_quality_hourly_default_ts_utc_idx; Type: INDEX ATTACH; Schema: core; Owner: postgres
--

ALTER INDEX core.idx_fact_quality_hourly_ts ATTACH PARTITION core.fact_quality_hourly_default_ts_utc_idx;


--
-- Name: kpi_confidence_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_entity_ts ATTACH PARTITION kpi.kpi_confidence_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_confidence_2023_03_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2023_03_pkey;


--
-- Name: kpi_confidence_2023_03_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_run ATTACH PARTITION kpi.kpi_confidence_2023_03_run_id_idx;


--
-- Name: kpi_confidence_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_ts ATTACH PARTITION kpi.kpi_confidence_2023_03_ts_utc_idx;


--
-- Name: kpi_confidence_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_entity_ts ATTACH PARTITION kpi.kpi_confidence_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_confidence_2024_03_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2024_03_pkey;


--
-- Name: kpi_confidence_2024_03_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_run ATTACH PARTITION kpi.kpi_confidence_2024_03_run_id_idx;


--
-- Name: kpi_confidence_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_ts ATTACH PARTITION kpi.kpi_confidence_2024_03_ts_utc_idx;


--
-- Name: kpi_confidence_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_entity_ts ATTACH PARTITION kpi.kpi_confidence_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_confidence_2024_04_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2024_04_pkey;


--
-- Name: kpi_confidence_2024_04_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_run ATTACH PARTITION kpi.kpi_confidence_2024_04_run_id_idx;


--
-- Name: kpi_confidence_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_ts ATTACH PARTITION kpi.kpi_confidence_2024_04_ts_utc_idx;


--
-- Name: kpi_confidence_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_entity_ts ATTACH PARTITION kpi.kpi_confidence_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_confidence_2025_01_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_confidence ATTACH PARTITION kpi.kpi_confidence_2025_01_pkey;


--
-- Name: kpi_confidence_2025_01_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_run ATTACH PARTITION kpi.kpi_confidence_2025_01_run_id_idx;


--
-- Name: kpi_confidence_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_ts ATTACH PARTITION kpi.kpi_confidence_2025_01_ts_utc_idx;


--
-- Name: kpi_confidence_default_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_entity_ts ATTACH PARTITION kpi.kpi_confidence_default_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_confidence_default_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_confidence ATTACH PARTITION kpi.kpi_confidence_default_pkey;


--
-- Name: kpi_confidence_default_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_run ATTACH PARTITION kpi.kpi_confidence_default_run_id_idx;


--
-- Name: kpi_confidence_default_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_conf_ts ATTACH PARTITION kpi.kpi_confidence_default_ts_utc_idx;


--
-- Name: kpi_value_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_entity_ts ATTACH PARTITION kpi.kpi_value_2023_03_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_value_2023_03_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_value ATTACH PARTITION kpi.kpi_value_2023_03_pkey;


--
-- Name: kpi_value_2023_03_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_run ATTACH PARTITION kpi.kpi_value_2023_03_run_id_idx;


--
-- Name: kpi_value_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_ts ATTACH PARTITION kpi.kpi_value_2023_03_ts_utc_idx;


--
-- Name: kpi_value_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_entity_ts ATTACH PARTITION kpi.kpi_value_2024_03_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_value_2024_03_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_value ATTACH PARTITION kpi.kpi_value_2024_03_pkey;


--
-- Name: kpi_value_2024_03_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_run ATTACH PARTITION kpi.kpi_value_2024_03_run_id_idx;


--
-- Name: kpi_value_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_ts ATTACH PARTITION kpi.kpi_value_2024_03_ts_utc_idx;


--
-- Name: kpi_value_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_entity_ts ATTACH PARTITION kpi.kpi_value_2024_04_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_value_2024_04_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_value ATTACH PARTITION kpi.kpi_value_2024_04_pkey;


--
-- Name: kpi_value_2024_04_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_run ATTACH PARTITION kpi.kpi_value_2024_04_run_id_idx;


--
-- Name: kpi_value_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_ts ATTACH PARTITION kpi.kpi_value_2024_04_ts_utc_idx;


--
-- Name: kpi_value_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_entity_ts ATTACH PARTITION kpi.kpi_value_2025_01_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_value_2025_01_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_value ATTACH PARTITION kpi.kpi_value_2025_01_pkey;


--
-- Name: kpi_value_2025_01_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_run ATTACH PARTITION kpi.kpi_value_2025_01_run_id_idx;


--
-- Name: kpi_value_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_ts ATTACH PARTITION kpi.kpi_value_2025_01_ts_utc_idx;


--
-- Name: kpi_value_default_entity_type_entity_id_ts_utc_kpi_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_entity_ts ATTACH PARTITION kpi.kpi_value_default_entity_type_entity_id_ts_utc_kpi_id_idx;


--
-- Name: kpi_value_default_pkey; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.pk_kpi_value ATTACH PARTITION kpi.kpi_value_default_pkey;


--
-- Name: kpi_value_default_run_id_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_run ATTACH PARTITION kpi.kpi_value_default_run_id_idx;


--
-- Name: kpi_value_default_ts_utc_idx; Type: INDEX ATTACH; Schema: kpi; Owner: postgres
--

ALTER INDEX kpi.idx_kpi_value_ts ATTACH PARTITION kpi.kpi_value_default_ts_utc_idx;


--
-- Name: ml_anomaly_score_hourly_2023_03_pkey; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.pk_ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2023_03_pkey;


--
-- Name: ml_anomaly_score_hourly_2023_03_run_id_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_run ATTACH PARTITION ml.ml_anomaly_score_hourly_2023_03_run_id_idx;


--
-- Name: ml_anomaly_score_hourly_2023_03_ts_utc_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_ts ATTACH PARTITION ml.ml_anomaly_score_hourly_2023_03_ts_utc_idx;


--
-- Name: ml_anomaly_score_hourly_2024_03_pkey; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.pk_ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_03_pkey;


--
-- Name: ml_anomaly_score_hourly_2024_03_run_id_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_run ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_03_run_id_idx;


--
-- Name: ml_anomaly_score_hourly_2024_03_ts_utc_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_ts ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_03_ts_utc_idx;


--
-- Name: ml_anomaly_score_hourly_2024_04_pkey; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.pk_ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_04_pkey;


--
-- Name: ml_anomaly_score_hourly_2024_04_run_id_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_run ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_04_run_id_idx;


--
-- Name: ml_anomaly_score_hourly_2024_04_ts_utc_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_ts ATTACH PARTITION ml.ml_anomaly_score_hourly_2024_04_ts_utc_idx;


--
-- Name: ml_anomaly_score_hourly_2025_01_pkey; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.pk_ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_2025_01_pkey;


--
-- Name: ml_anomaly_score_hourly_2025_01_run_id_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_run ATTACH PARTITION ml.ml_anomaly_score_hourly_2025_01_run_id_idx;


--
-- Name: ml_anomaly_score_hourly_2025_01_ts_utc_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_ts ATTACH PARTITION ml.ml_anomaly_score_hourly_2025_01_ts_utc_idx;


--
-- Name: ml_anomaly_score_hourly_default_pkey; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.pk_ml_anomaly_score_hourly ATTACH PARTITION ml.ml_anomaly_score_hourly_default_pkey;


--
-- Name: ml_anomaly_score_hourly_default_run_id_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_run ATTACH PARTITION ml.ml_anomaly_score_hourly_default_run_id_idx;


--
-- Name: ml_anomaly_score_hourly_default_ts_utc_idx; Type: INDEX ATTACH; Schema: ml; Owner: postgres
--

ALTER INDEX ml.idx_ml_anomaly_score_hourly_ts ATTACH PARTITION ml.ml_anomaly_score_hourly_default_ts_utc_idx;


--
-- Name: qa_features_hourly qa_features_hourly_det_id15_fkey; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE analytics.qa_features_hourly
    ADD CONSTRAINT qa_features_hourly_det_id15_fkey FOREIGN KEY (det_id15) REFERENCES core.dim_detector(det_id15);


--
-- Name: qa_features_hourly qa_features_hourly_run_id_fkey; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE analytics.qa_features_hourly
    ADD CONSTRAINT qa_features_hourly_run_id_fkey FOREIGN KEY (run_id) REFERENCES monitoring.pipeline_run(run_id);


--
-- Name: qa_features_hourly qa_features_hourly_ts_utc_fkey; Type: FK CONSTRAINT; Schema: analytics; Owner: postgres
--

ALTER TABLE analytics.qa_features_hourly
    ADD CONSTRAINT qa_features_hourly_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: dim_detector dim_detector_mq_id15_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE ONLY core.dim_detector
    ADD CONSTRAINT dim_detector_mq_id15_fkey FOREIGN KEY (mq_id15) REFERENCES core.dim_mq(mq_id15);


--
-- Name: fact_detector_hourly fact_detector_hourly_det_id15_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_detector_hourly
    ADD CONSTRAINT fact_detector_hourly_det_id15_fkey FOREIGN KEY (det_id15) REFERENCES core.dim_detector(det_id15);


--
-- Name: fact_detector_hourly fact_detector_hourly_ts_utc_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_detector_hourly
    ADD CONSTRAINT fact_detector_hourly_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: fact_detector_hourly fact_detector_hourly_vehicle_class_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_detector_hourly
    ADD CONSTRAINT fact_detector_hourly_vehicle_class_id_fkey FOREIGN KEY (vehicle_class_id) REFERENCES core.dim_vehicle_class(vehicle_class_id);


--
-- Name: fact_mq_hourly fact_mq_hourly_mq_id15_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_mq_hourly
    ADD CONSTRAINT fact_mq_hourly_mq_id15_fkey FOREIGN KEY (mq_id15) REFERENCES core.dim_mq(mq_id15);


--
-- Name: fact_mq_hourly fact_mq_hourly_ts_utc_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_mq_hourly
    ADD CONSTRAINT fact_mq_hourly_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: fact_mq_hourly fact_mq_hourly_vehicle_class_id_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_mq_hourly
    ADD CONSTRAINT fact_mq_hourly_vehicle_class_id_fkey FOREIGN KEY (vehicle_class_id) REFERENCES core.dim_vehicle_class(vehicle_class_id);


--
-- Name: fact_quality_hourly fact_quality_hourly_det_id15_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_quality_hourly
    ADD CONSTRAINT fact_quality_hourly_det_id15_fkey FOREIGN KEY (det_id15) REFERENCES core.dim_detector(det_id15);


--
-- Name: fact_quality_hourly fact_quality_hourly_ts_utc_fkey; Type: FK CONSTRAINT; Schema: core; Owner: postgres
--

ALTER TABLE core.fact_quality_hourly
    ADD CONSTRAINT fact_quality_hourly_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: run_files run_files_run_id_fkey; Type: FK CONSTRAINT; Schema: ingestion; Owner: postgres
--

ALTER TABLE ONLY ingestion.run_files
    ADD CONSTRAINT run_files_run_id_fkey FOREIGN KEY (run_id) REFERENCES ingestion.ingestion_runs(run_id) ON DELETE CASCADE;


--
-- Name: run_files run_files_source_url_fkey; Type: FK CONSTRAINT; Schema: ingestion; Owner: postgres
--

ALTER TABLE ONLY ingestion.run_files
    ADD CONSTRAINT run_files_source_url_fkey FOREIGN KEY (source_url) REFERENCES ingestion.file_manifest(source_url) ON DELETE RESTRICT;


--
-- Name: kpi_confidence fk_kpi_conf_to_value; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_confidence
    ADD CONSTRAINT fk_kpi_conf_to_value FOREIGN KEY (kpi_id, ts_utc, entity_type, entity_id) REFERENCES kpi.kpi_value(kpi_id, ts_utc, entity_type, entity_id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: kpi_confidence kpi_confidence_kpi_id_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_confidence
    ADD CONSTRAINT kpi_confidence_kpi_id_fkey FOREIGN KEY (kpi_id) REFERENCES kpi.kpi_definition(kpi_id);


--
-- Name: kpi_confidence kpi_confidence_run_id_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_confidence
    ADD CONSTRAINT kpi_confidence_run_id_fkey FOREIGN KEY (run_id) REFERENCES monitoring.pipeline_run(run_id);


--
-- Name: kpi_confidence kpi_confidence_ts_utc_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_confidence
    ADD CONSTRAINT kpi_confidence_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: kpi_value kpi_value_kpi_id_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_value
    ADD CONSTRAINT kpi_value_kpi_id_fkey FOREIGN KEY (kpi_id) REFERENCES kpi.kpi_definition(kpi_id);


--
-- Name: kpi_value kpi_value_run_id_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_value
    ADD CONSTRAINT kpi_value_run_id_fkey FOREIGN KEY (run_id) REFERENCES monitoring.pipeline_run(run_id);


--
-- Name: kpi_value kpi_value_ts_utc_fkey; Type: FK CONSTRAINT; Schema: kpi; Owner: postgres
--

ALTER TABLE kpi.kpi_value
    ADD CONSTRAINT kpi_value_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: ml_anomaly_score_hourly ml_anomaly_score_hourly_det_id15_fkey; Type: FK CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ml.ml_anomaly_score_hourly
    ADD CONSTRAINT ml_anomaly_score_hourly_det_id15_fkey FOREIGN KEY (det_id15) REFERENCES core.dim_detector(det_id15);


--
-- Name: ml_anomaly_score_hourly ml_anomaly_score_hourly_run_id_fkey; Type: FK CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ml.ml_anomaly_score_hourly
    ADD CONSTRAINT ml_anomaly_score_hourly_run_id_fkey FOREIGN KEY (run_id) REFERENCES monitoring.pipeline_run(run_id);


--
-- Name: ml_anomaly_score_hourly ml_anomaly_score_hourly_ts_utc_fkey; Type: FK CONSTRAINT; Schema: ml; Owner: postgres
--

ALTER TABLE ml.ml_anomaly_score_hourly
    ADD CONSTRAINT ml_anomaly_score_hourly_ts_utc_fkey FOREIGN KEY (ts_utc) REFERENCES core.dim_time_hour(ts_utc);


--
-- Name: traffic_rows traffic_rows_run_id_fkey; Type: FK CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.traffic_rows
    ADD CONSTRAINT traffic_rows_run_id_fkey FOREIGN KEY (run_id) REFERENCES ingestion.ingestion_runs(run_id) ON DELETE RESTRICT;


--
-- Name: traffic_rows traffic_rows_source_url_fkey; Type: FK CONSTRAINT; Schema: raw; Owner: postgres
--

ALTER TABLE ONLY raw.traffic_rows
    ADD CONSTRAINT traffic_rows_source_url_fkey FOREIGN KEY (source_url) REFERENCES ingestion.file_manifest(source_url) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict XfssvufVOfU3bXygO4UnjLSKWDCNgrGyo0fXgrA6NIM101aSp4ci3gIqMMaX6BK

