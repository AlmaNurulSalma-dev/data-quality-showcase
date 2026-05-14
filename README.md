# Data Quality Showcase 🔍

A production-grade data quality monitoring system built with **Python**, **dbt Core**, and **SQLite** — demonstrating enterprise data engineering practices from raw messy data all the way to a tested, monitored data warehouse.

---

## 🎯 Project Overview

This project simulates a real-world data pipeline where raw data arrives with quality issues. The system:

1. **Generates** intentionally messy data with 20+ quality issues
2. **Cleans** it through a staging layer using dbt
3. **Transforms** it into a star schema data warehouse
4. **Validates** everything with 55 automated tests
5. **Monitors** quality with an observability layer

---

## 🏗️ Architecture

```
Raw Data (CSV, Parquet, JSONL)
        ↓
  Staging Layer          ← Clean, deduplicate, normalize
        ↓
   Mart Layer            ← Star schema (dims + facts)
        ↓
Elementary Layer         ← Quality scores + trend tracking
```

---

## 📁 Project Structure

```
data-quality-showcase/
├── scripts/
│   ├── generate_data.py        # Generates 5 messy raw data files
│   ├── load_data.py            # Loads raw data into SQLite
│   └── check_db.py             # Utility to verify table row counts
├── data/                       # Raw data files (CSV, Parquet, JSONL)
├── models/
│   ├── staging/                # 5 staging models - data cleaning
│   │   ├── stg_customers.sql
│   │   ├── stg_products.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_order_items.sql
│   │   ├── stg_events.sql
│   │   └── sources.yml
│   ├── marts/                  # 6 mart models - star schema
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   │   ├── dim_dates.sql
│   │   ├── fct_orders.sql
│   │   ├── fct_order_items.sql
│   │   └── fct_events.sql
│   └── elementary/             # 3 observability models
│       ├── data_quality_score.sql
│       ├── quality_trends.sql
│       └── dim_data_quality.sql
├── tests/                      # 14 custom SQL tests
├── dbt_project.yml
├── packages.yml
└── profiles.yml
```

---

## 🐛 Intentional Data Quality Issues

| File | Format | Issues Injected |
|------|--------|----------------|
| raw_customers.csv | CSV | 2 duplicates, 3 null emails, 2 invalid ages, inconsistent status casing |
| raw_products.csv | CSV | 2 negative prices, 1 zero price, 2 null names, inconsistent categories |
| raw_orders.csv | CSV | 1 null order_id, 2 invalid customer refs, 2 negative amounts, 2 future dates |
| raw_order_items.parquet | Parquet | 2 orphaned records, 2 zero quantities, 1 calculation mismatch |
| raw_events.jsonl | JSONL | 3 null customer_ids, 2 invalid event types, 2 future timestamps, 1 duplicate |

---

## 🧹 Staging Layer — What Gets Cleaned

| Model | Cleaning Applied |
|-------|----------------|
| stg_customers | Deduplicate by customer_id, filter null emails, filter invalid ages (0-120), normalize status to lowercase |
| stg_products | Filter null names, filter negative/zero prices, normalize category to lowercase |
| stg_orders | Filter null order_ids, filter invalid customer refs, filter negative amounts, filter future dates |
| stg_order_items | Filter orphaned records, filter zero/negative quantities, recalculate line_total |
| stg_events | Deduplicate by event_id, filter null customer_ids, filter invalid event types, filter future timestamps |

**Raw → Clean row counts:**

| Table | Raw | Clean | Removed |
|-------|-----|-------|---------|
| customers | 25 | 18 | 7 |
| products | 21 | 16 | 5 |
| orders | 22 | 11 | 11 |
| order_items | 15 | 4 | 11 |
| events | 16 | 8 | 8 |

---

## ⭐ Mart Layer — Star Schema

```
                    dim_dates
                        |
dim_customers ── fct_orders ── dim_products
                        |
                 fct_order_items
                        |
                    fct_events
```

| Model | Type | Rows | Description |
|-------|------|------|-------------|
| dim_customers | Dimension | 10 | Active customers with age groups and regions |
| dim_products | Dimension | 16 | Products with price tiers and stock status |
| dim_dates | Dimension | 1826 | Full calendar 2023-2027 |
| fct_orders | Fact | 11 | Order transactions |
| fct_order_items | Fact | 4 | Line item details |
| fct_events | Fact | 8 | User behavior events |

---

## ✅ Test Coverage — 55 Tests, 100% Passing

| Dimension | Tests | Description |
|-----------|-------|-------------|
| Completeness | 18 | All required fields are non-null |
| Uniqueness | 5 | All IDs and keys are unique |
| Validity | 8 | Values conform to business rules |
| Consistency | 2 | Formats and casing are standardized |
| Referential Integrity | 5 | All foreign keys are valid |
| Timeliness | 2 | No future-dated records |
| Accuracy | 1 | Calculated fields are mathematically correct |
| Custom Business Rules | 14 | Project-specific validations |
| **Total** | **55** | **100% passing** |

---

## 📊 Observability Layer

| Model | Description |
|-------|-------------|
| data_quality_score | Daily quality scores broken down by dimension |
| quality_trends | 30-day trend tracking with 7-day moving average |
| dim_data_quality | Test coverage per model with quality tiers |

---

## 🚀 Quick Start

### 1. Install dependencies
```bash
py -3.12 -m pip install dbt-core dbt-sqlite pandas faker openpyxl pyarrow
```

### 2. Install dbt packages
```bash
dbt deps
```

### 3. Generate raw data
```bash
py -3.12 scripts/generate_data.py
```

### 4. Load data into SQLite
```bash
py -3.12 scripts/load_data.py
```

### 5. Run all models
```bash
dbt run
```

### 6. Run all tests
```bash
dbt test
```

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| Python 3.12 | Data generation |
| Faker | Realistic fake data |
| Pandas | Data manipulation |
| dbt Core 1.11 | Transformation & testing |
| dbt-sqlite | SQLite adapter |
| Elementary | Observability package |
| SQLite | Local database |
| Git | Version control |

---

## 💡 Key Concepts Demonstrated

- **Multi-format ingestion** — CSV, Parquet, JSONL
- **Data cleaning patterns** — deduplication, null handling, type casting, normalization
- **Star schema design** — dimension and fact tables with surrogate keys
- **Comprehensive testing** — 6 quality dimensions covered
- **Observability** — quality scoring and trend tracking
- **Professional git workflow** — incremental commits per feature

---

