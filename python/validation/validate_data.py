from pathlib import Path
import pandas as pd
ROOT=Path(__file__).resolve().parents[2]
DATA=ROOT/"data"/"raw"
required=["dim_date","dim_production_line","dim_equipment","dim_product","dim_customer",
"fact_orders","fact_production_runs","fact_equipment_downtime","fact_quality","fact_customer_feedback","fact_staffing"]
frames={n:pd.read_csv(DATA/f"{n}.csv") for n in required}
for name,df in frames.items():
    print(f"{name:30s} rows={len(df):8,} null_cells={int(df.isna().sum().sum()):,}")
# Primary-key uniqueness checks
for name,df in frames.items():
    pk=df.columns[0]
    assert df[pk].notna().all(), f"Null primary key in {name}"
    assert df[pk].is_unique, f"Duplicate primary key in {name}"
# Business checks
runs=frames["fact_production_runs"]
assert (runs.quantity_produced>=runs.scrap_quantity).all()
assert (runs.operating_minutes<=runs.planned_production_minutes).all()
quality=frames["fact_quality"]
assert (quality.good_quantity+quality.defect_quantity==quality.inspected_quantity).all()
assert set(runs.order_id).issubset(set(frames["fact_orders"].order_id))
assert set(quality.run_id).issubset(set(runs.run_id))
assert set(frames["fact_equipment_downtime"].run_id).issubset(set(runs.run_id))
print("PASS: primary keys, core quantity rules and foreign-key references validated.")
