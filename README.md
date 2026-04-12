# KPI Confidence – Streamlit (Final Package)

This package is **standalone** and runs in two modes:

- **DB mode (preferred):** reads from your Postgres views:
  - `bi.vw_kpi_hourly_enriched`
  - `bi.vw_kpi_daily_enriched`
  - `bi.vw_kpi_confidence_hourly_enriched` (optional)
  - `ingestion.file_history`
  - `ml.ml_anomaly_score_hourly` (optional; page 2 will use if available)

- **Demo mode (automatic fallback):** if the DB connection fails, the app will load **bundled demo data**
  so you can still present the UI **without getting stuck on connection issues**.

## 1) Create & activate venv (Windows PowerShell)
```powershell
python -m venv venv
venv\Scripts\activate
python -m pip install --upgrade pip
pip install -r requirements.txt
```

## 2) Configure environment
Create a file named `.env` in the project root (same folder as `app.py`).

### Option A (recommended): one connection string
```
DATABASE_URL=postgresql://USER:PASSWORD@HOST:PORT/DBNAME
```

### Option B (fallback): individual fields
```
PGHOST=localhost
PGPORT=5432
PGDATABASE=Version_1_db
PGUSER=postgres
PGPASSWORD=your_password
```

Timezone used in UI: **Europe/Berlin** (display only).

## 3) Run
```powershell
streamlit run app.py
```

## Notes
- UI labels:
  - `detector` -> "Detektor"
  - `global` -> "Gesamt (alle Detektoren)"
- The app **does not assume MQ**. If MQ appears later in the DB, it will show as an additional option automatically.
