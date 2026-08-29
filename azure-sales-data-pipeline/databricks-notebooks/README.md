# Azure Car Sales Data Pipeline

An end-to-end data engineering pipeline built on Azure that ingests raw car sales data, processes it through a **medallion architecture (Bronze → Silver → Gold)**, and models it into a **star schema** for analytics — using parameterized ingestion, SQL-based incremental watermarking, and Delta Lake upsert logic in Databricks.

---

## Architecture

```
                    ┌─────────────────┐
   Source CSV  ───► │  Azure Data     │  ───►  Azure SQL DB
  (GitHub-hosted)    │  Factory (ADF)  │        (source_cars_data)
                    └─────────────────┘
                            │
                 Watermark-based incremental
                 load (Lookup + Copy Activity)
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Stored Procedure     │
                 │ UpdateWatermarkTable │
                 └─────────────────────┘
                            │
                            ▼
        ┌──────────────────────────────────────┐
        │   Azure Databricks (PySpark / Delta)  │
        │                                        │
        │   Bronze ──► Silver ──► Gold           │
        │  (raw)     (cleansed,   (star schema:  │
        │             derived      dim + fact    │
        │             columns)     tables)       │
        └──────────────────────────────────────┘
```

**Pipeline flow (screenshot below):** `Lookup (last_load / current_load)` → `Copy Data (incremental)` → `Stored Procedure (watermark update)` → `Silver Notebook` → `Gold Dimension Notebooks (Branch, Dealer, Model, Date)` → `Gold Fact Sales Notebook`

![Pipeline overview](docs/screenshots/increm_data_pipeline_overview.png)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Orchestration | Azure Data Factory |
| Storage (raw/bronze) | Azure Data Lake Storage Gen2 |
| Relational staging | Azure SQL Database |
| Transformation & modeling | Azure Databricks (PySpark, Delta Lake) |
| Incremental logic | SQL watermark table + stored procedure |

---

## Key Design Decisions

**Parameterized ingestion** — datasets in ADF use parameters instead of hardcoded paths/tables, so the pipeline can be pointed at new source files without rebuilding activities.

**Watermark-based incremental loading** — rather than reloading the full dataset on every run, a `water_table` in Azure SQL tracks the last-loaded `Date_ID`. Each run's Lookup activities compare `last_load` vs. `current_load` (max `Date_ID` in source) so only new records are copied. A stored procedure (`UpdateWatermarkTable`) updates the watermark after each successful load.

**Medallion architecture in Databricks** —
- **Bronze:** raw ingested data, unmodified
- **Silver:** cleansed data with derived columns (`Model_Category`, `RevPerUnit`) for downstream analytics
- **Gold:** dimensional star schema — 4 dimension tables (`dim_branch`, `dim_dealer`, `dim_model`, `dim_date`) and one fact table (`factsales`)

**SCD Type 1 (upsert) logic** — each Gold-layer notebook generates surrogate keys for new dimension records and uses Delta Lake's `MERGE` to upsert: existing records are updated, new records are inserted, all in a single idempotent operation. An `incremental_flag` parameter distinguishes first-run (full load) from subsequent (incremental) runs.

**Databricks Workflow orchestration** — in addition to running notebooks as activities inside the ADF pipeline, the same Silver → Gold transformation chain was also implemented as a native Databricks Workflow, demonstrating orchestration at both the ADF and Databricks layers.

---

## Repository Structure

```
├── adf/                      ADF pipeline export (ARM template)
├── sql/                      Table creation + stored procedure scripts
├── databricks-notebooks/     Silver transformation + Gold dimension/fact notebooks
├── databricks-workflow/      Screenshots of the native Databricks Workflow version
├── data/                     Sample source datasets (see data/README.md)
└── docs/screenshots/         Pipeline run screenshots and results
```

---

## Testing: Full Load vs. Incremental Load

The pipeline was tested against two datasets (see `data/README.md` for details):
- **Full load:** `SalesData.csv` — 1,849 records
- **Incremental load:** `IncrementalSales_batch.csv` — 200 records continuing the same `Date_ID` sequence, used to validate that the watermark logic correctly identifies and processes only new records rather than reprocessing the full dataset.

*(Run durations and row counts to be added here once the comparison test is finalized — see `docs/screenshots/pipeline_run_history.png` for run history.)*

---

## Status

This project is actively being built. Core pipeline (ingestion, watermarking, Silver/Gold transformation, dimensional modeling) is functional and has been tested with multiple successful pipeline runs. Remaining work: finalized full-vs-incremental performance metrics, and BI-layer consumption (planned).

---

## Dataset

Sample car sales transaction data (branch, dealer, model, revenue, units sold). See `data/README.md` for schema and details.
