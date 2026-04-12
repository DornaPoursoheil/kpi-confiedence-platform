from __future__ import annotations

from pathlib import Path
import pandas as pd


BASE_DIR = Path(__file__).resolve().parents[1] / "data" / "demo"


FILE_MAP = {
    "year_months": "year_months.csv",
    "kpi_hourly": "kpi_hourly.csv",
    "kpi_daily": "kpi_daily.csv",
    "detector_lookup": "detector_lookup.csv",
    "anomaly_overview": "anomaly_overview.csv",
    "missing_rate": "missing_rate.csv",
}


def _safe_read_csv(name: str) -> pd.DataFrame:
    if name not in FILE_MAP:
        return pd.DataFrame()

    path = BASE_DIR / FILE_MAP[name]

    if not path.exists():
        return pd.DataFrame()

    df = pd.read_csv(path)

    # Normalize datetime columns if present
    if "ts_utc" in df.columns:
        df["ts_utc"] = pd.to_datetime(df["ts_utc"], errors="coerce", utc=True)

    if "d_utc" in df.columns:
        df["d_utc"] = pd.to_datetime(df["d_utc"], errors="coerce")

    # Normalize numeric filter columns if present
    for col in ["year_utc", "month_utc", "day_utc", "hour_utc"]:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    return df


def load_demo_data(name: str, params: dict | None = None) -> pd.DataFrame:
    """
    Load demo data from CSV files and optionally apply filters.

    Supported names:
    - year_months
    - kpi_hourly
    - kpi_daily
    - detector_lookup
    - anomaly_overview
    - missing_rate
    """
    params = params or {}
    df = _safe_read_csv(name)

    if df.empty:
        return df

    # -----------------------------
    # Common filters
    # -----------------------------
    if "year" in params and "year_utc" in df.columns:
        df = df[df["year_utc"] == params["year"]]

    if "month" in params and "month_utc" in df.columns:
        df = df[df["month_utc"] == params["month"]]

    if "entity_type" in params and "entity_type" in df.columns:
        df = df[df["entity_type"].astype(str) == str(params["entity_type"])]

    # -----------------------------
    # Time window filters
    # -----------------------------
    if "ts_from" in params and "ts_utc" in df.columns:
        ts_from = pd.to_datetime(params["ts_from"], errors="coerce", utc=True)
        if pd.notna(ts_from):
            df = df[df["ts_utc"] >= ts_from]

    if "ts_to" in params and "ts_utc" in df.columns:
        ts_to = pd.to_datetime(params["ts_to"], errors="coerce", utc=True)
        if pd.notna(ts_to):
            df = df[df["ts_utc"] < ts_to]

    # -----------------------------
    # Normalize IDs
    # -----------------------------
    if "entity_id" in df.columns:
        df["entity_id"] = df["entity_id"].astype(str).str.strip()

    if "det_id15" in df.columns:
        df["det_id15"] = df["det_id15"].astype(str).str.strip()

    return df.reset_index(drop=True)