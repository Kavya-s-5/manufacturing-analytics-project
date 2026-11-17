# Manufacturing Analytics Project (Synthetic)

## Scope
End-to-end manufacturing KPI analytics for 2022-2026 using MySQL, Python/Pandas and Power BI.

## Contents
- `data/raw/`: generated CSVs for all 11 database tables.
- `python/data_generation/generate_data.py`: deterministic synthetic data generator.
- `python/validation/validate_data.py`: primary-key, quantity and reference checks.
- `sql/01_create_database_and_tables.sql`: MySQL database and table DDL.
- `sql/02_load_csv_data.sql`: CSV loading statements.
- `sql/03_kpi_views_and_checks.sql`: KPI definitions, views and validation queries.
- `sql/04_create_aggregate_tables.sql`: dashboard aggregate tables.
- `dashboard/POWER_BI_GUIDE.md`: Power BI connection and visual guide.
- `documentation/INFERENCE_REPORT.md`: illustrative data findings and caveats.

## Quick start
1. Install Python 3.10+ and MySQL 8.0+.
2. From the project root create a virtual environment:
   `python3 -m venv .venv`
3. Activate it: `source .venv/bin/activate`
4. Install dependencies: `pip install -r requirements.txt`
5. Regenerate data (optional): `python python/data_generation/generate_data.py`
6. Validate CSVs: `python python/validation/validate_data.py`
7. In MySQL Workbench, run `sql/01_create_database_and_tables.sql`.
8. Run `sql/02_load_csv_data.sql` after changing paths to absolute paths if needed and enabling LOCAL INFILE. Load order is already arranged for foreign keys.
9. Run `sql/03_kpi_views_and_checks.sql`.
10. Run `sql/04_create_aggregate_tables.sql`.
11. Follow `dashboard/POWER_BI_GUIDE.md`.

## KPI definitions
- Availability = operating minutes / planned production minutes.
- Performance = (units produced × ideal cycle seconds) / (operating minutes × 60).
- Quality = good units / units produced.
- OEE = Availability × Performance × Quality.
- Yield = good units / inspected units (equivalent to good / produced in this synthetic model).
- Scrap rate = scrap units / produced units.
- Cycle time = end timestamp - start timestamp, in minutes.
- Customer satisfaction = positive feedback (rating 4 or 5) / all feedback responses.

## Synthetic-data warning
All names, customers, plants, operational records and KPI values are fictional and generated for learning/project demonstration. They are not actual company data or evidence of real factory performance.
