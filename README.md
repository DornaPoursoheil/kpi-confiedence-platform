# kpi-confidence-platform

## 🚀 Projektübersicht

Die KPI Confidence Platform ist ein End-to-End Data Analytics Projekt zur Berechnung, Überwachung und Bewertung von KPIs inklusive eines **Confidence Scores (0–1)**.

Ziel ist es, nicht nur Kennzahlen darzustellen, sondern auch deren **Vertrauenswürdigkeit basierend auf Datenqualität und Anomalie-Erkennung** transparent zu machen.

---

## 🎯 Business Problem

In klassischen BI-Systemen werden KPIs visualisiert, ohne dass die Qualität der zugrunde liegenden Daten klar ersichtlich ist.

Dieses Projekt adressiert dieses Problem durch:

- Data Quality Monitoring  
- Confidence Scoring je KPI  
- ML-basierte Anomalie-Erkennung  

👉 Ergebnis: **KPI + Vertrauen in KPI**

---

## 📊 Datengrundlage

- Berliner Verkehrsdetektion (Open Data)
- Stündliche Messwerte pro Detektor (Geschwindigkeit, Fahrzeuganzahl)
- Zeitraum: historische und aktuelle Daten (2017 – heute)
- Formate: `.gz` (historisch) / `.tgz` (neu)

---


## 🏗️ Systemarchitektur

Die Plattform besteht aus einer mehrstufigen Datenpipeline:

### 1. Ingestion
- Orchestrierung über n8n (Workflow 1)
- ETag & SHA256 Checks zur Vermeidung redundanter Loads
- FastAPI-Endpunkte zur Steuerung der Pipeline

### 2. Staging
- Trennung von alten und neuen Datenquellen
- Speicherung in staging-Tabellen (PostgreSQL)

### 3. Core / Analytics
- Verarbeitung durch Python Engine
- Aufbau von Fakt-Tabellen (z. B. `fact_detector_hourly`)
- Data Quality Features (Missing Rate, Duplicates, Freshness)

### 4. ML Layer
- Anomalie-Erkennung mit Median Absolute Deviation (MAD)
- Robuste Z-Score-Berechnung für Zeitreihen

### 5. BI & Output
- Power BI (Management Dashboard)
- Streamlit (Data Quality & Debugging Tool)
- Slack Alerts für Monitoring

👉 Orchestrierung erfolgt vollständig über n8n (Workflow 1 & 2)

---
## 👥 Meine Rolle im Projekt

Dieses Projekt wurde im Team entwickelt.

Mein Fokus lag auf:

- Orchestrierung der Datenpipeline mit n8n  
- Entwicklung der Streamlit-Anwendung für Analyse und Debugging  
- Unterstützung bei der Datenmodellierung in PostgreSQL  

Weitere Komponenten wie die Python Processing Engine und ML-Modelle wurde im Team umgesetzt.

 ---
 
## ⚙️ Technologien

- Python (Data Processing & Pipeline Engine)
- PostgreSQL (Datenhaltung & Modellierung)
- n8n (Workflow-Orchestrierung)
- FastAPI (Pipeline-Steuerung)
- Streamlit (Analyse & Debugging)
- Power BI (Business Reporting)

---

## 🧠 Kernfunktionen

- KPI-Berechnung (Flow, Speed, Aggregationen)
- Data Quality Checks:
  - Vollständigkeit
  - Konsistenz
  - Duplikate
  - Aktualität
- Confidence Score je KPI (0–1)
- ML-basierte Anomalie-Erkennung (MAD)
- End-to-End Monitoring der Pipeline

---

## 📈 Confidence Scoring

Der Confidence Score basiert auf:

- Datenvollständigkeit  
- Konsistenz der Zeitreihe  
- Anomalie-Flags (ML)  
- Datenintegrität (ETag / SHA256)

### Bewertung

| Score | Bedeutung |
|------|----------|
| 0.85 – 1.00 | Hoch (zuverlässig) |
| 0.60 – 0.84 | Mittel |
| < 0.60 | Niedrig |

---

## 🤖 ML-Ansatz

Anomalie-Erkennung mittels:

**Median Absolute Deviation (MAD)**

modified_z = 0.6745 × (x − median) / MAD
     
- Schwellenwert: |z| > 3.5 → Anomalie  
- Robust gegenüber Ausreißern  

---

## 🔄 Pipeline Design

- Modular aufgebaut  
- Idempotent (wiederholbar)  
- Config-driven  
- Guardrail-Validierung (rc=42 = Skip, nicht fatal)  

👉 Fokus: **Zuverlässigkeit, Skalierbarkeit und Stabilität**

---

## 📊 Visualisierung

**Power BI**
- KPI Trends  
- Confidence Score  
- Anomalie-Rate  

**Streamlit**
- Technische Analyse  
- Anomalie-Highlighting  
- Debugging Tool  

---

## 🎯 Ziel

Dieses Projekt demonstriert:

- Data Engineering  
- Data Analytics  
- BI & Reporting  
- Data Quality Management  

---

## 📫 Kontakt

- LinkedIn: https://www.linkedin.com/in/dorna-poursoheil-data  
- Standort: Deutschland
