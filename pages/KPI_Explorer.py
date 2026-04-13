from __future__ import annotations

import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st
import warnings
import sys

from src.db import can_connect, get_config, read_sql_df
from src.demo_data import load_demo_data
from src.queries import KPI_DAILY, KPI_HOURLY, YEAR_MONTHS, DETECTOR_LIST
from src.ui import apply_entity_labels, label_entity_type

# ===============================
# Demo Mode Switch
# ===============================
DEMO_MODE = True


# ===============================
# Cache Layer
# ===============================
@st.cache_data(ttl=1800, show_spinner=False)
def load_kpi_data(query: str, params: dict) -> pd.DataFrame:
    if DEMO_MODE:
        if query == KPI_HOURLY:
            return load_demo_data("kpi_hourly", params)
        if query == KPI_DAILY:
            return load_demo_data("kpi_daily", params)
        return pd.DataFrame()

    cfg = get_config()
    return read_sql_df(cfg, query, params)


@st.cache_data(ttl=3600, show_spinner=False)
def load_detector_lookup() -> pd.DataFrame:
    if DEMO_MODE:
        return load_demo_data("detector_lookup", {})
    cfg = get_config()
    return read_sql_df(cfg, DETECTOR_LIST, {})


@st.cache_data(ttl=3600, show_spinner=False)
def load_yearmonths() -> pd.DataFrame:
    if DEMO_MODE:
        return load_demo_data("year_months", {})
    cfg = get_config()
    return read_sql_df(cfg, YEAR_MONTHS, {})


@st.cache_data(ttl=900, show_spinner=False)
def prepare_overview_frames(
    data: pd.DataFrame,
    entity_type: str,
    mode: str,
    confidence_col: str,
    value_col: str,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """
    Returns:
      overview_health
      stability_df
      temporal_df
    """
    work = data.copy()

    # time normalization once
    if mode == "Hourly" and "ts_utc" in work.columns:
        work["ts_utc"] = pd.to_datetime(work["ts_utc"], errors="coerce", utc=True)
    elif mode == "Daily" and "d_utc" in work.columns:
        work["d_utc"] = pd.to_datetime(work["d_utc"], errors="coerce")

    # ---------------------------
    # Overview health
    # ---------------------------
    overview_health = pd.DataFrame()
    if entity_type == "detector" and confidence_col in work.columns and value_col in work.columns:
        group_cols = ["entity_id"]
        if "vehicle_class" in work.columns:
            group_cols.append("vehicle_class")

        overview_health = (
            work.groupby(group_cols, dropna=False)
            .agg(
                avg_confidence=(confidence_col, "mean"),
                avg_value=(value_col, "mean"),
                periods=(confidence_col, "count"),
            )
            .reset_index()
        )

    # ---------------------------
    # Stability
    # ---------------------------
    stability_df = pd.DataFrame()
    if entity_type == "detector" and confidence_col in work.columns:
        stability_df = (
            work.groupby("entity_id", dropna=False)
            .agg(
                avg_conf=(confidence_col, "mean"),
                low_conf_periods=(confidence_col, lambda s: (pd.to_numeric(s, errors="coerce") < 0.5).sum()),
            )
            .reset_index()
        )

    # ---------------------------
    # Temporal frame
    # ---------------------------
    temporal_df = pd.DataFrame()
    if mode == "Hourly" and "ts_utc" in work.columns and confidence_col in work.columns:
        temporal_df = work[["ts_utc", confidence_col]].dropna().copy()
        temporal_df["hour"] = temporal_df["ts_utc"].dt.hour
        temporal_df["day"] = temporal_df["ts_utc"].dt.date

    return overview_health, stability_df, temporal_df


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
        + df["lat_wgs84"].round(6).astype(str)
        + ", "
        + df["lon_wgs84"].round(6).astype(str)
        + ")"
    )


# ===============================
# Page Config
# ===============================
st.set_page_config(page_title="KPI Explorer", page_icon="🛰", layout="wide")

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

st.markdown('<div class="main-title">🛰 KPI Explorer</div>', unsafe_allow_html=True)
st.markdown(
    '<div class="subtle">KPI values + confidence from the BI layer. Focus: Berlin detector overview and system health.</div>',
    unsafe_allow_html=True,
)

if not DEMO_MODE:
    cfg = get_config()
    ok, err = can_connect(cfg)

    if not ok:
        st.error(f"Database connection failed: {err}")
        st.stop()
else:
    st.info("Demo mode is active. Data is loaded from local demo files, not from PostgreSQL.")

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
# Base Filtered Data
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
# Detector Lookup
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
# Prepared Frames (performance)
# ===============================
overview_health, stability_df, temporal_df = prepare_overview_frames(
    data=base_df,
    entity_type=entity_type,
    mode=mode,
    confidence_col=confidence_col,
    value_col=value_col,
)

if entity_type == "detector" and not overview_health.empty:
    overview_health["health"] = overview_health["avg_confidence"].apply(health_label)
    overview_health = overview_health.merge(
        detector_lookup[["det_id15", "lat_wgs84", "lon_wgs84", "label"]],
        left_on="entity_id",
        right_on="det_id15",
        how="left",
    )
    overview_health = overview_health.dropna(subset=["lat_wgs84", "lon_wgs84"]).copy()

# ===============================
# BERLIN MAP
# ===============================
if entity_type == "detector" and not overview_health.empty:
    st.markdown("## 🗺 Berlin Traffic Sensor Map")

    st.markdown('<div class="section-title">🗺 Berlin Detector Overview</div>', unsafe_allow_html=True)
    st.markdown(
        f"""
        <div class="legend-box">
        <b>Map meaning:</b> each point is a detector in Berlin.<br>
        <b>Color</b> = confidence health, <b>size</b> = number of available periods,
        <b>value</b> = <b>{value_label}</b>.
        All filters from the sidebar affect this map.
        </div>
        """,
        unsafe_allow_html=True,
    )

    fig_map = go.Figure()

    # density layer
    fig_map.add_trace(
        go.Densitymapbox(
            lat=overview_health["lat_wgs84"],
            lon=overview_health["lon_wgs84"],
            z=overview_health["periods"],
            radius=20,
            colorscale="Turbo",
            showscale=False,
            opacity=0.35,
        )
    )

    # marker layer
    max_periods = max(float(overview_health["periods"].max()), 1.0)
    fig_map.add_trace(
        go.Scattermapbox(
            lat=overview_health["lat_wgs84"],
            lon=overview_health["lon_wgs84"],
            mode="markers",
            marker=dict(
                size=(overview_health["periods"] / max_periods) * 18 + 6,
                color=overview_health["avg_confidence"],
                colorscale=[
                    [0, "#e74c3c"],
                    [0.7, "#f1c40f"],
                    [0.9, "#2ecc71"],
                ],
                cmin=0,
                cmax=1,
                showscale=True,
                colorbar=dict(title="Confidence"),
            ),
            text=overview_health["entity_id"],
            customdata=overview_health[["avg_value", "periods"]].values,
            hovertemplate=(
                "<b>Detector</b>: %{text}<br>"
                "Confidence: %{marker.color:.2f}<br>"
                "Value: %{customdata[0]:.1f}<br>"
                "Periods: %{customdata[1]}<extra></extra>"
            ),
        )
    )

    fig_map.update_layout(
        mapbox=dict(
            style="open-street-map",
            center=dict(lat=52.5200, lon=13.4050),
            zoom=11,
        ),
        margin=dict(l=0, r=0, t=0, b=0),
        height=650,
    )

    st.plotly_chart(fig_map, use_container_width=True)

# ===============================
# DETECTOR HEALTH OVERVIEW
# ===============================
if entity_type == "detector" and not overview_health.empty:
    st.markdown('<div class="section-title">🛰 Detector Health Overview</div>', unsafe_allow_html=True)
    st.markdown(
        f"""
        <div class="legend-box">
        X-axis = average <b>{value_label}</b><br>
        Y-axis = average confidence<br>
        Bubble size = available periods in the selected month<br>
        Color = detector health level
        </div>
        """,
        unsafe_allow_html=True,
    )

    color_map = {
        "High": "#2ecc71",
        "Medium": "#f1c40f",
        "Low": "#e74c3c",
    }

    facet_vehicle = "vehicle_class" if ("vehicle_class" in overview_health.columns and vehicle == "all") else None

    fig_health = px.scatter(
        overview_health,
        x="avg_value",
        y="avg_confidence",
        size="periods",
        color="health",
        hover_name="entity_id",
        hover_data={
            "avg_value": ":.2f",
            "avg_confidence": ":.2f",
            "periods": True,
            "vehicle_class": True if "vehicle_class" in overview_health.columns else False,
            "label": True,
        },
        template="plotly_dark",
        color_discrete_map=color_map,
        facet_col=facet_vehicle,
        labels={
            "avg_value": value_label,
            "avg_confidence": "Average Confidence",
            "periods": "Available Periods",
            "vehicle_class": "Vehicle Class",
        },
        height=560 if facet_vehicle else 500,
    )

    fig_health.update_layout(
        yaxis_range=[0, 1.05],
        margin=dict(l=40, r=20, t=60, b=40),
        legend_title_text="Health",
    )
    st.plotly_chart(fig_health, use_container_width=True)

# ===============================
# SENSOR STABILITY MAP
# ===============================
st.subheader("Sensor Stability Map")

if entity_type == "detector" and not stability_df.empty:
    fig_stability = px.scatter(
        stability_df,
        x="low_conf_periods",
        y="avg_conf",
        size="low_conf_periods",
        color="avg_conf",
        color_continuous_scale="Turbo",
        title="Detector Stability Overview",
        template="plotly_dark",
    )
    st.plotly_chart(fig_stability, use_container_width=True)
else:
    st.info("Detector-level analysis available only for entity = detector.")

# ===============================
# TEMPORAL CONFIDENCE PATTERN
# ===============================
st.subheader("Temporal Confidence Pattern")

if mode == "Hourly" and not temporal_df.empty:
    pivot = temporal_df.pivot_table(
        values=confidence_col,
        index="hour",
        columns="day",
        aggfunc="mean",
    )

    ampel_scale = [
        [0.0, "#e74c3c"],
        [0.4, "#e74c3c"],
        [0.4, "#f1c40f"],
        [0.7, "#f1c40f"],
        [0.7, "#2ecc71"],
        [1.0, "#2ecc71"],
    ]

    fig_temporal = px.imshow(
        pivot,
        aspect="auto",
        color_continuous_scale=ampel_scale,
        zmin=0,
        zmax=1,
        title="Confidence Heatmap (Hour vs Day)",
    )

    fig_temporal.update_layout(
        template="plotly_dark",
        coloraxis_colorbar=dict(
            title="Confidence",
            tickvals=[0.2, 0.55, 0.85],
            ticktext=["Bad", "Medium", "Good"],
        ),
    )

    st.plotly_chart(fig_temporal, use_container_width=True)
else:
    st.info("Temporal confidence heatmap is available in Hourly mode only.")