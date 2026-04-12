from __future__ import annotations

import datetime as dt
import calendar
import warnings
import sys

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

from src.db import can_connect, get_config, read_sql_df
from src.demo_data import load_demo_data
from src.queries import (
    KPI_DIAGNOSTICS,
    ML_ANOMALY,
    QA_MISSING,
    YEAR_MONTHS,
    DETECTOR_LIST,
    KPI_DAILY,
    KPI_HOURLY,
    ANOMALY_OVERVIEW,
    MISSING_RATE,
    ANOMALY_BY_STREET,
    ANOMALY_BY_SENSOR,
)
from src.ui import apply_entity_labels, label_entity_type


# ===============================
# Demo Mode Switch
# ===============================
DEMO_MODE = True


# ===============================
# Cache Layer
# ===============================
@st.cache_data(ttl=1800, show_spinner=False)
def load_kpi_data(query, params):
    if DEMO_MODE:
        if query == KPI_HOURLY:
            return load_demo_data("kpi_hourly", params)
        if query == KPI_DAILY:
            return load_demo_data("kpi_daily", params)
        return pd.DataFrame()

    cfg = get_config()
    return read_sql_df(cfg, query, params)


@st.cache_data(ttl=3600, show_spinner=False)
def load_detector_lookup():
    if DEMO_MODE:
        return load_demo_data("detector_lookup", {})
    cfg = get_config()
    return read_sql_df(cfg, DETECTOR_LIST, {})


@st.cache_data(ttl=3600, show_spinner=False)
def load_yearmonths():
    if DEMO_MODE:
        return load_demo_data("year_months", {})
    cfg = get_config()
    return read_sql_df(cfg, YEAR_MONTHS, {})


@st.cache_data(ttl=1800, show_spinner=False)
def load_data(query, params):
    if DEMO_MODE:
        # Optional demo extensions:
        if query == ANOMALY_OVERVIEW:
            return load_demo_data("anomaly_overview", params)
        if query == MISSING_RATE:
            return load_demo_data("missing_rate", params)
        return pd.DataFrame()

    cfg = get_config()
    return read_sql_df(cfg, query, params)


# =============================
# page Einstellung
# =============================
st.set_page_config(page_title="Stability & Confidence Deep Dive", page_icon="🧠", layout="wide")

st.title("🧠 Data Quality Diagnostics")
st.caption(
    """
Operational observability of detector stability.

Focus:
• unstable sensors
• anomaly behaviour
• missing data impact
"""
)

if not DEMO_MODE:
    cfg = get_config()
    ok, err = can_connect(cfg)

    if not ok:
        st.error(f"Database connection failed: {err}")
        st.stop()
else:
    ok, err = True, None
    st.info("Demo mode is active. Data is loaded from demo data, not from PostgreSQL.")


# ===============================
# Helper Functions
# ===============================
def get_value_column(mode: str) -> str:
    return "value" if mode == "Hourly" else "value_avg"


def get_confidence_column(mode: str) -> str:
    return "confidence_score" if mode == "Hourly" else "confidence_score_avg"


def get_time_column(mode: str) -> str:
    return "ts_utc" if mode == "Hourly" else "d_utc"


def get_confidence_label_column(mode: str, df: pd.DataFrame) -> str | None:
    if mode == "Hourly" and "confidence_label" in df.columns:
        return "confidence_label"
    if mode == "Daily" and "confidence_label_daily" in df.columns:
        return "confidence_label_daily"
    if "confidence_label" in df.columns:
        return "confidence_label"
    if "confidence_label_daily" in df.columns:
        return "confidence_label_daily"
    return None


def infer_value_label(kpi_family: str | None) -> str:
    if not kpi_family:
        return "Selected KPI Value"

    k = str(kpi_family).lower()

    if "speed" in k or "geschwindigkeit" in k:
        return "Speed (km/h)"
    if "flow" in k or "volume" in k or "count" in k or "verkehr" in k:
        return "Flow / Volume (vehicles/hour)"

    return "Selected KPI Value"


def health_label(c: float) -> str:
    if pd.isna(c):
        return "Unknown"
    if c >= 0.9:
        return "High"
    if c >= 0.7:
        return "Medium"
    return "Low"


def safe_unique_sorted(df: pd.DataFrame, col: str) -> list[str]:
    if col not in df.columns:
        return []
    return sorted(df[col].dropna().astype(str).unique().tolist())


def make_detector_label(df: pd.DataFrame) -> pd.Series:
    lat = pd.to_numeric(df["lat_wgs84"], errors="coerce")
    lon = pd.to_numeric(df["lon_wgs84"], errors="coerce")

    return (
        df["det_id15"].fillna("").astype(str)
        + " — "
        + df["strasse"].fillna("").astype(str)
        + " / "
        + df["richtung"].fillna("").astype(str)
        + " / "
        + df["position"].fillna("").astype(str)
        + " / Spur "
        + df["spur"].fillna("").astype(str)
        + " / ("
        + lat.round(6).astype(str)
        + ", "
        + lon.round(6).astype(str)
        + ")"
    )


# ===============================
# Page Styles
# ===============================
st.markdown(
    """
    <style>
    .main-title {
        font-size: 34px;
        font-weight: 800;
        margin-bottom: 0.2rem;
    }
    .subtle {
        color: #A0A7B4;
        margin-bottom: 1rem;
    }
    .filter-box {
        background: linear-gradient(180deg, #111827 0%, #0F172A 100%);
        padding: 16px;
        border-radius: 16px;
        border: 1px solid rgba(255,255,255,0.08);
        box-shadow: 0 10px 28px rgba(0,0,0,0.25);
        margin-bottom: 12px;
    }
    .metric-card {
        padding: 18px;
        border-radius: 16px;
        background: #111827;
        border: 1px solid rgba(255,255,255,0.08);
        box-shadow: 0 8px 24px rgba(0,0,0,0.25);
        text-align: center;
        min-height: 112px;
    }
    .metric-title {
        font-size: 15px;
        color: #A0A7B4;
        margin-bottom: 10px;
    }
    .metric-value {
        font-size: 28px;
        font-weight: 800;
        color: #F8FAFC;
    }
    .metric-note {
        font-size: 13px;
        color: #94A3B8;
        margin-top: 8px;
    }
    .section-title {
        font-size: 24px;
        font-weight: 750;
        margin-top: 8px;
        margin-bottom: 6px;
    }
    .legend-box {
        background: #0F172A;
        padding: 14px 16px;
        border-radius: 14px;
        border: 1px solid rgba(255,255,255,0.07);
        margin-bottom: 10px;
    }
    </style>
    """,
    unsafe_allow_html=True,
)

# ===============================
# Sidebar
# ===============================
with st.sidebar:
    st.subheader("🎛 Filters")

    mode = st.radio("Granularity", ["Hourly", "Daily"], index=0)

    entity_type = st.selectbox(
        "Entity",
        ["detector", "global"],
        index=0,
        format_func=label_entity_type,
    )

    st.divider()

# ===============================
# Data Load
# ===============================
year_month_df = load_yearmonths()

if year_month_df.empty:
    st.info("No data available.")
    st.stop()

year_month_df["year_utc"] = pd.to_numeric(year_month_df["year_utc"], errors="coerce")
year_month_df["month_utc"] = pd.to_numeric(year_month_df["month_utc"], errors="coerce")
year_month_df = year_month_df.dropna(subset=["year_utc", "month_utc"]).copy()

year_month_df["year_utc"] = year_month_df["year_utc"].astype(int)
year_month_df["month_utc"] = year_month_df["month_utc"].astype(int)

year_month_df["year_month"] = (
    year_month_df["year_utc"].astype(str)
    + "_"
    + year_month_df["month_utc"].astype(str).str.zfill(2)
)

year_month_df = year_month_df.sort_values(["year_utc", "month_utc"], ascending=[False, False])
available_yearmonths = year_month_df["year_month"].drop_duplicates().tolist()

with st.sidebar:
    st.markdown('<div class="filter-box">', unsafe_allow_html=True)
    yearmonth_selected = st.selectbox("Year_Month", available_yearmonths, index=0)
    st.markdown("</div>", unsafe_allow_html=True)

year_selected = int(yearmonth_selected.split("_")[0])
month_selected = int(yearmonth_selected.split("_")[1])

params = {
    "year": year_selected,
    "month": month_selected,
    "entity_type": entity_type,
}

if mode == "Hourly":
    df = load_kpi_data(KPI_HOURLY, params)
else:
    df = load_kpi_data(KPI_DAILY, params)

# ===============================
# Post Processing
# ===============================
df = apply_entity_labels(df)

if df.empty:
    st.info("No data for selected filters.")
    st.stop()

df = df.copy()

if "entity_id" in df.columns:
    df["entity_id"] = df["entity_id"].astype(str).str.strip()

x = get_time_column(mode)
value_col = get_value_column(mode)
confidence_col = get_confidence_column(mode)
confidence_label_col = get_confidence_label_column(mode, df)

if x not in df.columns:
    st.error(f"Expected time column '{x}' not found.")
    st.stop()

kpi_families = safe_unique_sorted(df, "kpi_family")
veh = safe_unique_sorted(df, "vehicle_class")
confidence_labels = safe_unique_sorted(df, confidence_label_col) if confidence_label_col else []

if not kpi_families:
    st.error("No KPI families found in data.")
    st.stop()

# ===============================
# Main Filters (Sidebar Box)
# ===============================
with st.sidebar:
    st.divider()
    st.subheader("📌 KPI Selection")

    kpi_family = st.selectbox("KPI Family", kpi_families)

    vehicle_options = ["all"] + veh if veh else ["all"]
    vehicle = st.selectbox("Vehicle Class", vehicle_options)

    if mode == "Daily":
        measure_options = [c for c in ["value_avg", "confidence_score_avg"] if c in df.columns]
    else:
        measure_options = [c for c in ["value", "confidence_score"] if c in df.columns]

    measure = st.selectbox("Measure", measure_options)

    confidence_filter_options = ["all"] + confidence_labels if confidence_labels else ["all"]
    confidence_filter = st.selectbox("Confidence Level", confidence_filter_options)

value_label = infer_value_label(kpi_family)

# ===============================
# Base Filtered Data (Overview Level)
# ===============================
base_df = df.copy()

if "kpi_family" in base_df.columns:
    base_df = base_df[base_df["kpi_family"].astype(str) == str(kpi_family)]

if vehicle != "all" and "vehicle_class" in base_df.columns:
    base_df = base_df[base_df["vehicle_class"].astype(str) == str(vehicle)]

if (
    confidence_filter != "all"
    and confidence_label_col is not None
    and confidence_label_col in base_df.columns
):
    base_df = base_df[base_df[confidence_label_col].astype(str) == str(confidence_filter)]

if base_df.empty:
    st.warning("No data after applying KPI / vehicle / confidence filters.")
    st.stop()

# ===============================
# Detector Lookup for Overview
# ===============================
detector_lookup = pd.DataFrame()

if entity_type == "detector":
    try:
        detector_lookup = load_detector_lookup()[
            ["det_id15", "strasse", "richtung", "position", "spur", "lat_wgs84", "lon_wgs84"]
        ].copy()
    except Exception:
        detector_lookup = pd.DataFrame()

    if detector_lookup.empty:
        st.warning("Detector lookup could not be loaded.")
        st.stop()

    detector_lookup["det_id15"] = detector_lookup["det_id15"].astype(str).str.strip()
    detector_lookup = detector_lookup.drop_duplicates("det_id15")

    for col in ["strasse", "richtung", "position", "spur", "lat_wgs84", "lon_wgs84"]:
        if col not in detector_lookup.columns:
            detector_lookup[col] = None

    detector_lookup["lat_wgs84"] = pd.to_numeric(detector_lookup["lat_wgs84"], errors="coerce")
    detector_lookup["lon_wgs84"] = pd.to_numeric(detector_lookup["lon_wgs84"], errors="coerce")

    detectors_with_data = set(base_df["entity_id"].astype(str).str.strip())
    detector_lookup = detector_lookup[detector_lookup["det_id15"].isin(detectors_with_data)].copy()

    if detector_lookup.empty:
        st.warning("No detector options available for the selected overview filters.")
        st.stop()

    detector_lookup["label"] = make_detector_label(detector_lookup)

# ===============================
# Overview Health Data
# ===============================
overview_health = pd.DataFrame()

if entity_type == "detector" and confidence_col in base_df.columns and value_col in base_df.columns:
    group_cols = ["entity_id"]
    if "vehicle_class" in base_df.columns:
        group_cols.append("vehicle_class")

    overview_health = (
        base_df.groupby(group_cols, dropna=False)
        .agg(
            avg_confidence=(confidence_col, "mean"),
            avg_value=(value_col, "mean"),
            periods=(confidence_col, "count"),
        )
        .reset_index()
    )

    overview_health["health"] = overview_health["avg_confidence"].apply(health_label)

    overview_health = overview_health.merge(
        detector_lookup[["det_id15", "lat_wgs84", "lon_wgs84", "label"]],
        left_on="entity_id",
        right_on="det_id15",
        how="left",
    )

    overview_health = overview_health.dropna(subset=["lat_wgs84", "lon_wgs84"]).copy()

# ===============================
# Detector Selector (after Overview)
# ===============================
selected_detector_id = None
selected_detector_label = None

if entity_type == "detector":
    st.markdown('<div class="section-title">🎯 Detector Drilldown</div>', unsafe_allow_html=True)

    detector_labels = sorted(detector_lookup["label"].dropna().astype(str).tolist())
    detector_map = dict(zip(detector_lookup["label"], detector_lookup["det_id15"]))

    selected_detector_label = st.selectbox(
        "Select a detector for detailed drilldown",
        detector_labels,
    )
    selected_detector_id = str(detector_map[selected_detector_label]).strip()

# ===============================
# Plot Data (Final Selection)
# ===============================
plot_df = base_df.copy()

if entity_type == "detector" and selected_detector_id is not None:
    plot_df = plot_df[plot_df["entity_id"].astype(str).str.strip() == selected_detector_id]

if plot_df.empty:
    st.warning("No data for the selected detector.")
    st.stop()

plot_df = plot_df.sort_values(x).copy()

# ===============================
# Data Quality Overview (Drilldown Level)
# ===============================
days_in_month = calendar.monthrange(year_selected, month_selected)[1]
total_hours = days_in_month * 24

if mode == "Hourly":
    visible_hours = plot_df["ts_utc"].nunique() if "ts_utc" in plot_df.columns else len(plot_df)
else:
    visible_hours = plot_df["d_utc"].nunique() * 24 if "d_utc" in plot_df.columns else len(plot_df)

coverage_pct = round((visible_hours / total_hours) * 100, 1)
missing_hours = max(total_hours - visible_hours, 0)

conf_share = {}
if confidence_label_col is not None and confidence_label_col in plot_df.columns:
    conf_share = (
        plot_df[confidence_label_col]
        .astype(str)
        .value_counts(normalize=True)
        .mul(100)
        .round(1)
        .to_dict()
    )

st.markdown('<div class="section-title">📊 Data Quality Overview</div>', unsafe_allow_html=True)

m1, m2, m3, m4, m5 = st.columns(5)

with m1:
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-title">📡 Coverage</div>
            <div class="metric-value">{coverage_pct}%</div>
            <div class="metric-note">Selected view in current month</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with m2:
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-title">⏱ Visible Hours</div>
            <div class="metric-value">{visible_hours} / {total_hours}</div>
            <div class="metric-note">Hours represented by current selection</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with m3:
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-title">⚠ Missing Hours</div>
            <div class="metric-value">{missing_hours}</div>
            <div class="metric-note">Expected month hours not visible</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with m4:
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-title">🟢 High</div>
            <div class="metric-value">{conf_share.get('high', 0)}%</div>
            <div class="metric-note">Share of selected periods</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with m5:
    med_low = round(conf_share.get("medium", 0) + conf_share.get("low", 0), 1)
    st.markdown(
        f"""
        <div class="metric-card">
            <div class="metric-title">🟡/🔴 Medium+Low</div>
            <div class="metric-value">{med_low}%</div>
            <div class="metric-note">Potential quality concern share</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

# ===============================
# Confidence Distribution
# ===============================
col1, col2 = st.columns(2)

with col1:
    if confidence_col in plot_df.columns:
        st.markdown('<div class="section-title">📈 Confidence Distribution</div>', unsafe_allow_html=True)

        conf_df = plot_df[[confidence_col]].dropna().copy()
        conf_df[confidence_col] = pd.to_numeric(conf_df[confidence_col], errors="coerce")
        conf_df = conf_df[(conf_df[confidence_col] >= 0) & (conf_df[confidence_col] <= 1)]

        conf_df["bin"] = pd.cut(
            conf_df[confidence_col],
            bins=10,
            include_lowest=True
        )

        conf_dist = (
            conf_df["bin"]
            .value_counts(normalize=True)
            .sort_index()
            .mul(100)
            .reset_index()
        )

        conf_dist.columns = ["confidence_range", "percent"]
        conf_dist["confidence_range"] = conf_dist["confidence_range"].astype(str)

        fig_hist = px.bar(
            conf_dist,
            x="confidence_range",
            y="percent",
            template="plotly_dark",
            labels={
                "confidence_range": "Confidence Score",
                "percent": "% of hours"
            },
            title="Confidence Score Distribution (%)"
        )

        st.plotly_chart(fig_hist, use_container_width=True)

with col2:
    if entity_type == "detector" and "vehicle_class" in plot_df.columns and confidence_label_col in plot_df.columns:
        st.markdown('<div class="section-title">🚗 Vehicle Confidence</div>', unsafe_allow_html=True)

        if vehicle != "all":
            df_vehicle = plot_df[plot_df["vehicle_class"] == vehicle]
        else:
            df_vehicle = plot_df.copy()

        vehicle_conf = (
            df_vehicle
            .groupby([confidence_label_col])
            .size()
            .reset_index(name="count")
        )

        vehicle_conf["percent"] = vehicle_conf["count"] / vehicle_conf["count"].sum() * 100

        conf_order = ["high", "medium", "low"]

        fig_vehicle = px.bar(
            vehicle_conf,
            x=["Selected Vehicle"] * len(vehicle_conf),
            y="percent",
            color=confidence_label_col,
            barmode="stack",
            template="plotly_dark",
            category_orders={confidence_label_col: conf_order},
            labels={
                "percent": "% of hours",
                confidence_label_col: "Confidence Level"
            },
            color_discrete_map={
                "high": "#2ecc71",
                "medium": "#f1c40f",
                "low": "#e74c3c"
            }
        )

        fig_vehicle.update_traces(
            texttemplate="%{y:.1f}%",
            textposition="inside"
        )

        fig_vehicle.update_layout(
            height=420,
            yaxis_title="% of hours",
            xaxis_title=f"Vehicle: {vehicle.upper()}",
            margin=dict(l=40, r=40, t=50, b=40),
            hovermode="x unified"
        )

        fig_vehicle.update_yaxes(range=[0, 100])

        st.plotly_chart(fig_vehicle, use_container_width=True)

# ===============================
# DETECTOR DAILY PATTERN HEATMAP
# ===============================
if entity_type == "detector" and value_col in plot_df.columns and "ts_utc" in plot_df.columns:
    st.subheader("🕒 Detector Daily Pattern")

    heat_df = plot_df.copy()
    heat_df["hour"] = pd.to_datetime(heat_df["ts_utc"], utc=True, errors="coerce").dt.hour
    heat_df["date"] = pd.to_datetime(heat_df["ts_utc"], utc=True, errors="coerce").dt.date

    pivot = heat_df.pivot_table(
        values=value_col,
        index="date",
        columns="hour",
        aggfunc="mean"
    )

    pivot = pivot.reindex(columns=range(24))

    fig_heat = px.imshow(
        pivot,
        aspect="auto",
        color_continuous_scale="Turbo",
        labels=dict(
            x="Hour of Day",
            y="Date",
            color=value_label
        )
    )

    fig_heat.update_layout(
        template="plotly_dark",
        height=420,
        margin=dict(l=40, r=40, t=40, b=40)
    )

    st.plotly_chart(fig_heat, use_container_width=True)

# ===============================
# DETECTOR CONFIDENCE HEATMAP
# ===============================
if entity_type == "detector" and confidence_col in plot_df.columns and "ts_utc" in plot_df.columns:
    st.subheader("🧠 Detector Confidence Pattern")

    conf_heat = plot_df.copy()
    conf_heat["hour"] = pd.to_datetime(conf_heat["ts_utc"], utc=True, errors="coerce").dt.hour
    conf_heat["date"] = pd.to_datetime(conf_heat["ts_utc"], utc=True, errors="coerce").dt.date

    pivot_conf = conf_heat.pivot_table(
        values=confidence_col,
        index="date",
        columns="hour",
        aggfunc="mean"
    )

    pivot_conf = pivot_conf.reindex(columns=range(24))

    fig_conf_heat = px.imshow(
        pivot_conf,
        aspect="auto",
        color_continuous_scale=[
            [0, "#e74c3c"],
            [0.7, "#f1c40f"],
            [1, "#2ecc71"]
        ],
        labels=dict(
            x="Hour of Day",
            y="Date",
            color="Confidence"
        )
    )

    fig_conf_heat.update_layout(
        template="plotly_dark",
        height=420,
        margin=dict(l=40, r=40, t=40, b=40)
    )

    st.plotly_chart(fig_conf_heat, use_container_width=True)

st.caption(
    f"Tip: current value metric is interpreted as '{value_label}'. Map and health overview follow all sidebar filters."
)

# =========================================================
# DATA QUALITY SIGNALS
# =========================================================
st.divider()

ts_from = dt.datetime(year_selected, month_selected, 1)

if month_selected == 12:
    ts_to = dt.datetime(year_selected + 1, 1, 1)
else:
    ts_to = dt.datetime(year_selected, month_selected + 1, 1)

time_params = {
    "ts_from": ts_from,
    "ts_to": ts_to
}

anom = pd.DataFrame()
miss = pd.DataFrame()

try:
    anom = load_data(ANOMALY_OVERVIEW, time_params)
except Exception:
    anom = pd.DataFrame()

try:
    miss = load_data(MISSING_RATE, time_params)
except Exception:
    miss = pd.DataFrame()

merged = base_df.copy()
merged["entity_id"] = merged["entity_id"].astype(str).str.strip()

if "ts_utc" in merged.columns:
    merged["ts_utc"] = pd.to_datetime(
        merged["ts_utc"],
        utc=True,
        errors="coerce"
    )

if len(anom):
    if "det_id15" in anom.columns:
        anom = anom.rename(columns={"det_id15": "entity_id"})

    anom["entity_id"] = anom["entity_id"].astype(str).str.strip()

    if "ts_utc" in anom.columns:
        anom["ts_utc"] = pd.to_datetime(
            anom["ts_utc"],
            utc=True,
            errors="coerce"
        )

if len(miss):
    if "det_id15" in miss.columns:
        miss = miss.rename(columns={"det_id15": "entity_id"})

    miss["entity_id"] = miss["entity_id"].astype(str).str.strip()

    if "ts_utc" in miss.columns:
        miss["ts_utc"] = pd.to_datetime(
            miss["ts_utc"],
            utc=True,
            errors="coerce"
        )

visible_entities = set(
    merged["entity_id"]
    .dropna()
    .astype(str)
    .tolist()
)

if len(anom) and "entity_id" in anom.columns:
    anom = anom[anom["entity_id"].isin(visible_entities)].copy()

if len(miss) and "entity_id" in miss.columns:
    miss = miss[miss["entity_id"].isin(visible_entities)].copy()

if len(miss) and {"entity_id", "ts_utc", "missing_rate"}.issubset(miss.columns):
    miss_small = miss[
        ["entity_id", "ts_utc", "missing_rate"]
    ].drop_duplicates()

    merged = merged.merge(
        miss_small,
        on=["entity_id", "ts_utc"],
        how="left"
    )

if len(anom) and {"entity_id", "ts_utc", "anomaly_score", "is_anomaly"}.issubset(anom.columns):
    keep_cols = ["entity_id", "ts_utc", "anomaly_score", "is_anomaly"]
    if "top_driver" in anom.columns:
        keep_cols.append("top_driver")

    anom_small = anom[keep_cols].drop_duplicates()

    merged = merged.merge(
        anom_small,
        on=["entity_id", "ts_utc"],
        how="left"
    )

# =========================================================
# DATA QUALITY CORRELATION
# =========================================================
col1, col2 = st.columns(2)

with col1:
    st.subheader("Data Quality Correlation")

    corr_cols = [
        "confidence_score",
        "value",
        "missing_rate",
        "anomaly_score"
    ]

    corr_cols = [c for c in corr_cols if c in merged.columns]

    if len(corr_cols) >= 2:
        corr_df = merged[corr_cols].copy()

        for c in corr_cols:
            corr_df[c] = pd.to_numeric(corr_df[c], errors="coerce")

        corr_matrix = corr_df.corr()

        fig_corr = px.imshow(
            corr_matrix,
            text_auto=".2f",
            color_continuous_scale="RdBu_r",
            zmin=-1,
            zmax=1,
            template="plotly_dark",
            title="Correlation between Data Quality Signals",
            aspect="auto"
        )

        fig_corr.update_layout(
            margin=dict(l=100, r=40, t=70, b=100),
            height=520
        )

        fig_corr.update_xaxes(tickangle=35)
        st.plotly_chart(fig_corr, use_container_width=True)
    else:
        st.caption("Not enough data quality signal columns available.")

with col2:
    st.subheader("Confidence Root Cause Matrix")

    driver_cols = [
        "missing_rate",
        "anomaly_score",
        "value"
    ]

    driver_cols = [c for c in driver_cols if c in merged.columns]

    if "confidence_score" in merged.columns and len(driver_cols):
        drivers = []

        for col in driver_cols:
            corr = merged["confidence_score"].corr(merged[col])

            drivers.append({
                "driver": col,
                "correlation": corr
            })

        drivers_df = pd.DataFrame(drivers)

        fig = px.bar(
            drivers_df,
            x="driver",
            y="correlation",
            color="correlation",
            color_continuous_scale="RdYlGn",
            range_y=[-1, 1],
            template="plotly_dark",
            title="Drivers impacting Confidence Score"
        )

        fig.update_layout(
            xaxis_title="Quality Driver",
            yaxis_title="Correlation with Confidence",
            height=430
        )

        st.plotly_chart(fig, use_container_width=True)
    else:
        st.caption("No driver metrics available.")

# =========================================================
# ANOMALY TIMELINE
# =========================================================
st.subheader("ML Anomaly Timeline")

if len(anom):
    fig = px.histogram(
        anom,
        x="ts_utc",
        nbins=30,
        color_discrete_sequence=["orange"],
        template="plotly_dark",
        title="Detected Anomalies over Time"
    )

    st.plotly_chart(fig, use_container_width=True)
else:
    st.caption("No ML anomaly data")

# =========================================================
# ANOMALY RATE BY SENSOR / STREET
# =========================================================
col1, col2 = st.columns(2)

with col1:
    st.subheader("Anomaly Rate by Sensor")

    if len(anom) and "is_anomaly" in anom.columns:
        rate = (
            anom.groupby("entity_id")
            .agg(
                anomaly_hours=("is_anomaly", "sum"),
                total_hours=("is_anomaly", "count")
            )
            .reset_index()
        )

        rate["anomaly_rate"] = rate["anomaly_hours"] / rate["total_hours"]
        rate = rate.sort_values("anomaly_rate", ascending=False).head(20)
        rate["rank"] = range(1, len(rate) + 1)

        def classify_sensor(r):
            if r <= 3:
                return "Critical (Top 3)"
            elif r <= 10:
                return "High (4–10)"
            return "Normal"

        rate["category"] = rate["rank"].apply(classify_sensor)

        fig = px.bar(
            rate,
            x="entity_id",
            y="anomaly_rate",
            color="category",
            template="plotly_dark",
            title="Top Sensors with Highest Anomaly Rate",
            color_discrete_map={
                "Critical (Top 3)": "#e74c3c",
                "High (4–10)": "#f39c12",
                "Normal": "#3498db"
            }
        )

        fig.update_layout(
            xaxis_title="Sensor (Detector)",
            yaxis_title="Anomaly Rate",
            legend_title="Risk Level",
            height=500
        )

        st.plotly_chart(fig, use_container_width=True)
    else:
        st.caption("No anomaly sensor data available.")

with col2:
    st.subheader("Anomaly Rate by Street")

    if entity_type == "detector" and not detector_lookup.empty and len(anom):
        anom_street = anom.merge(
            detector_lookup[["det_id15", "strasse"]],
            left_on="entity_id",
            right_on="det_id15",
            how="left"
        )

        anom_street = anom_street.dropna(subset=["strasse"])

        if not anom_street.empty:
            street_rate = (
                anom_street.groupby("strasse")
                .agg(
                    anomaly_hours=("is_anomaly", "sum"),
                    total_hours=("is_anomaly", "count")
                )
                .reset_index()
            )

            street_rate["anomaly_rate"] = street_rate["anomaly_hours"] / street_rate["total_hours"]
            street_rate = street_rate.sort_values("anomaly_rate", ascending=False).head(20)
            street_rate["rank"] = range(1, len(street_rate) + 1)

            def classify_street(r):
                if r <= 3:
                    return "Critical (Top 3)"
                elif r <= 10:
                    return "High (4–10)"
                return "Normal"

            street_rate["category"] = street_rate["rank"].apply(classify_street)

            fig = px.bar(
                street_rate,
                x="strasse",
                y="anomaly_rate",
                color="category",
                template="plotly_dark",
                title="Streets with Highest Sensor Anomaly Rate",
                color_discrete_map={
                    "Critical (Top 3)": "#e74c3c",
                    "High (4–10)": "#f39c12",
                    "Normal": "#3498db"
                }
            )

            fig.update_xaxes(tickangle=35)
            fig.update_layout(
                xaxis_title="Street",
                yaxis_title="Anomaly Rate",
                legend_title="Risk Level",
                height=500
            )

            st.plotly_chart(fig, use_container_width=True)
        else:
            st.caption("No street-level anomaly data available.")
    else:
        st.caption("No street-level anomaly data available.")