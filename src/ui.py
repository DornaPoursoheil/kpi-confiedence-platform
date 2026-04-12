from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

import pandas as pd


ENTITY_LABELS = {
    "detector": "Detektor",
    "global": "Gesamt (alle Detektoren)",
    "mq": "Messquerschnitt (MQ)",
}


def label_entity_type(entity_type: str) -> str:
    return ENTITY_LABELS.get(entity_type, entity_type)


def apply_entity_labels(df: pd.DataFrame) -> pd.DataFrame:
    if "entity_type" in df.columns:
        df = df.copy()
        df["entity_type_label"] = df["entity_type"].map(label_entity_type)
    return df


def safe_cols(df: pd.DataFrame, cols: Iterable[str]) -> list[str]:
    return [c for c in cols if c in df.columns]

