from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any, Optional

import pandas as pd
import psycopg
from psycopg.rows import dict_row
from dotenv import load_dotenv
import os
import os
print("DB FILE PATH:", __file__)
print("CURRENT WORKDIR:", os.getcwd())

print("DATABASE_URL ENV:", os.getenv("DATABASE_URL"))
print("PGPORT ENV:", os.getenv("PGPORT"))
print("PGDATABASE ENV:", os.getenv("PGDATABASE"))

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ENV_PATH = os.path.join(BASE_DIR, "..", ".env")

load_dotenv(dotenv_path=ENV_PATH)


@dataclass(frozen=True)
class DBConfig:
    dsn: str


def _build_dsn() -> str:

    host = os.getenv("PGHOST", "localhost")
    port = os.getenv("PGPORT", "5440")
    db = os.getenv("PGDATABASE", "postgres")
    user = os.getenv("PGUSER", "postgres")
    pwd = os.getenv("PGPASSWORD", "")

    auth = f"{user}:{pwd}@" if pwd else f"{user}@"
    return f"postgresql://{auth}{host}:{port}/{db}"




def get_config() -> DBConfig:
    return DBConfig(dsn=_build_dsn())


def can_connect(cfg: DBConfig, timeout_s: int = 3) -> tuple[bool, str]:
    try:
        with psycopg.connect(cfg.dsn, connect_timeout=timeout_s, row_factory=dict_row) as conn:
            with conn.cursor() as cur:
                cur.execute("select 1 as ok;")
                _ = cur.fetchone()
        return True, "ok"
    except Exception as e:
        return False, str(e)


def read_sql_df(cfg: DBConfig, sql: str, params: Optional[dict[str, Any]] = None) -> pd.DataFrame:
    params = params or {}
    with psycopg.connect(cfg.dsn, row_factory=dict_row) as conn:
        with conn.cursor() as cur:
            cur.execute(sql, params)
            rows = cur.fetchall()
    return pd.DataFrame(rows)



print("DSN:", _build_dsn())