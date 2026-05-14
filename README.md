# Data Quality Showcase

A production-grade data quality monitoring system built with **dbt Core**, **Python**, and **SQLite** — designed as a portfolio project demonstrating enterprise data engineering practices.

---

## 🎯 What This Project Demonstrates

- Multi-format data ingestion (CSV, Parquet, JSONL)
- Data cleaning & transformation with dbt (16 models)
- Comprehensive quality testing (40+ tests across 6 dimensions)
- Observability layer with quality scoring & trend tracking
- Star schema dimensional warehouse design
- Power BI dashboard for quality monitoring

---

## 🏗️ Architecture

```
Raw Data (messy)
  ↓
Staging Layer (clean, deduplicated)
  ↓
Mart Layer (star schema: dims + facts)
  ↓
Elementary Layer (quality scores + trends)
  ↓
Power BI Dashboard
```

---

## 📁 Project Structure

```
data-quality-showcase/
├── scripts/
│   └── generate_data.py        # Generates messy raw data
├── data/                       # Raw data files (CSV, Parquet, JSONL)
├── models/
│   ├── staging/                # 5 staging models (clean raw data)
│   ├── marts/                  # 7 mart models (star schema)
│   └── elementary/             # 4 observability models
├── tests/                      # 10+ custom SQL tests
├── docs/                       # Documentation
├── dbt_project.yml
├── packages.yml
└── profiles.yml
```

---

## 🚀 Quick Start

### 1. Install dependencies
```bash
pip install dbt-core dbt-sqlite pandas faker openpyxl pyarrow
```

### 2. Generate raw data
```bash
python scripts/generate_data.py
```

### 3. Install dbt packages
```bash
dbt deps
```

### 4. Run dbt models
```bash
dbt run
```

### 5. Run tests
```bash
dbt test
```

---

## 📊 Data Quality Issues (Intentional)

| File | Issues |
|------|--------|
| raw_customers.csv | Duplicates, null emails, invalid ages, inconsistent status casing |
| raw_products.csv | Negative prices, null names, inconsistent categories |
| raw_orders.csv | Null order IDs, invalid customer refs, negative amounts, future dates |
| raw_order_items.parquet | Orphaned records, zero quantities, calculation mismatches |
| raw_events.jsonl | Null customer IDs, invalid event types, future timestamps |

---

## ✅ Test Coverage

| Dimension | Tests |
|-----------|-------|
| Uniqueness | 5 |
| Completeness | 6 |
| Validity | 7 |
| Consistency | 5 |
| Referential Integrity | 5 |
| Business Rules | 7+ |
| Elementary Anomaly | 8 |
| **Total** | **40+** |

---

## 🛠️ Tech Stack

- **Python** + Faker — data generation
- **dbt Core** — transformation & testing
- **SQLite** — local database
- **Elementary** — observability & anomaly detection
- **Power BI** — dashboarding

---

## 📬 Contact

Built by Alma as a data engineering portfolio project.