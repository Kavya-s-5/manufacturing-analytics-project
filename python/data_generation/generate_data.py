"""
Rebuilds the synthetic manufacturing dataset for 2022-2026.
Run from project root: python3 python/data_generation/generate_data.py
The script is deterministic (seed=20261113) and writes CSV files to data/raw/.
"""
from pathlib import Path
import uuid, random
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "data" / "raw"
OUT.mkdir(parents=True, exist_ok=True)
SEED = 20261113
rng = np.random.default_rng(SEED)
py_rng = random.Random(SEED)
uid = lambda: str(uuid.uuid4())
dates = pd.date_range("2022-01-01", "2026-12-31", freq="D")

lines = pd.DataFrame([
    ("Assembly Line A","Chennai Plant","Automotive"),("Assembly Line B","Chennai Plant","Automotive"),
    ("Precision Line C","Hyderabad Plant","Industrial"),("Precision Line D","Hyderabad Plant","Industrial"),
    ("Packaging Line E","Pune Plant","Consumer"),("Packaging Line F","Pune Plant","Consumer"),
    ("Fabrication Line G","Coimbatore Plant","Industrial"),("Fabrication Line H","Coimbatore Plant","Automotive")
], columns=["line_name","location","line_type"])
lines.insert(0,"line_id",[uid() for _ in range(len(lines))])

equipment_rows=[]
for _, line in lines.iterrows():
    for n, typ in enumerate(["CNC Machine","Hydraulic Press","Robotic Arm"],1):
        equipment_rows.append({"equipment_id":uid(),"equipment_name":f"{line.line_name[-1]}-{typ.split()[0]}-{n:02d}",
            "line_id":line.line_id,"equipment_type":typ,
            "commissioned_date":(pd.Timestamp("2019-01-01")+pd.Timedelta(days=int(rng.integers(0,1500)))).date().isoformat(),
            "ideal_cycle_time_seconds":float(rng.choice([18,22,25,30,35,40,45,50]))})
equipment=pd.DataFrame(equipment_rows)
products=pd.DataFrame([
    ("Brake Assembly","Automotive"),("Steering Bracket","Automotive"),("Gear Housing","Automotive"),
    ("Hydraulic Valve","Industrial"),("Pump Impeller","Industrial"),("Control Panel","Industrial"),
    ("Smart Thermostat","Consumer"),("Power Adapter","Consumer"),("Protective Enclosure","Consumer"),
    ("Drive Shaft","Automotive"),("Mounting Plate","Industrial"),("Sensor Module","Consumer")
],columns=["product_name","category"])
products.insert(0,"product_id",[uid() for _ in range(len(products))])
first=["Aarav","Vihaan","Aditya","Ishaan","Rohan","Arjun","Ananya","Diya","Ira","Meera","Priya","Kavya","Nisha","Neha","Sana","Rahul","Kiran","Dev","Maya","Tara"]
last=["Sharma","Reddy","Iyer","Nair","Patel","Rao","Menon","Kulkarni","Das","Kapoor","Singh","Bhat","Joshi","Pillai","Ghosh"]
cities=["Chennai","Bengaluru","Hyderabad","Pune","Coimbatore","Mumbai","Kochi","Ahmedabad","Jaipur","Delhi"]
customers=pd.DataFrame([{"customer_id":uid(),"customer_name":f"{py_rng.choice(first)} {py_rng.choice(last)}",
    "location":py_rng.choice(cities),"customer_segment":py_rng.choices(["OEM","Distributor","Retail","Enterprise"],[.35,.30,.20,.15])[0]}
    for _ in range(180)])
date_dim=pd.DataFrame({"calendar_date":dates})
date_dim["date_id"]=date_dim.calendar_date.dt.strftime("%Y%m%d").astype(int)
date_dim["year"]=date_dim.calendar_date.dt.year
date_dim["quarter"]=date_dim.calendar_date.dt.quarter
date_dim["month"]=date_dim.calendar_date.dt.month
date_dim["month_name"]=date_dim.calendar_date.dt.strftime("%B")
date_dim["month_start"]=date_dim.calendar_date.dt.to_period("M").dt.to_timestamp().dt.date.astype(str)
date_dim["day_of_week"]=date_dim.calendar_date.dt.day_name()
date_dim["is_weekend"]=(date_dim.calendar_date.dt.dayofweek>=5).astype(int)
date_dim["season"]=date_dim.month.map({12:"Winter",1:"Winter",2:"Winter",3:"Summer",4:"Summer",5:"Summer",6:"Monsoon",7:"Monsoon",8:"Monsoon",9:"Monsoon",10:"Post-monsoon",11:"Post-monsoon"})
line_ids=lines.line_id.tolist(); prod_ids=products.product_id.tolist(); cust_ids=customers.customer_id.tolist()
equip_by_line={lid:equipment.loc[equipment.line_id==lid,"equipment_id"].tolist() for lid in line_ids}
ideal_by_line={lid:float(equipment.loc[equipment.line_id==lid,"ideal_cycle_time_seconds"].median()) for lid in line_ids}
prod_cat=products.set_index("product_id").category.to_dict()
seasonal={1:.88,2:.92,3:.96,4:.93,5:.98,6:1.02,7:1.05,8:1.08,9:1.02,10:1.13,11:1.22,12:1.30}
disruptions={(2023,7),(2024,8),(2025,6),(2026,9)}
orders=[]; runs=[]; quality=[]; downtime=[]; staffing=[]
for d in dates:
    peak=d.month in [10,11,12]
    holiday=.25 if ((d.month==12 and d.day>=24) or (d.month==1 and d.day<=2)) else 1
    supply=(d.year,d.month) in disruptions
    lam=4.2*seasonal[d.month]*(1+.055*(d.year-2022))*holiday*(.45 if d.dayofweek>=5 else 1)*(.72 if supply else 1)
    for _ in range(int(rng.poisson(lam))):
        oid,pid,cid,lid=uid(),py_rng.choice(prod_ids),py_rng.choice(cust_ids),py_rng.choice(line_ids)
        cat=prod_cat[pid]; qty=int(rng.integers(80,501))
        price=float({"Automotive":rng.uniform(35,120),"Industrial":rng.uniform(50,180),"Consumer":rng.uniform(15,90)}[cat])
        orders.append({"order_id":oid,"product_id":pid,"customer_id":cid,"order_date":d.date().isoformat(),
            "requested_quantity":qty,"unit_price":round(price,2),"promised_date":(d+pd.Timedelta(days=int(rng.integers(5,22)))).date().isoformat(),"order_status":"Completed"})
        staff_ratio=float(np.clip(rng.normal(.94 if peak else .97,.045),.78,1.05))
        planned=int(rng.integers(420,481))
        if d.dayofweek>=5 or holiday<1: planned=max(180,int(planned*.55))
        downtime_rate=float(np.clip(rng.normal(.075,.025)+(.075 if supply else 0)+(.025 if peak else 0),.02,.32))
        operating=max(30,int(planned*(1-downtime_rate))); ideal=ideal_by_line[lid]
        perf=float(np.clip(rng.normal(.91,.055)*(.92 if supply else 1)*(.96 if peak else 1)*staff_ratio,.65,1.05))
        produced=min(qty,max(1,int(round(operating*60/ideal*perf))))
        defect=float(np.clip(rng.normal(.035,.012)+(.025 if supply else 0)+(.012 if peak else 0)+(.012 if staff_ratio<.9 else 0),.005,.16))
        scrap=int(rng.binomial(produced,defect)); good=produced-scrap
        st=d+pd.Timedelta(hours=int(rng.integers(6,14)),minutes=int(rng.integers(0,60)))
        en=st+pd.Timedelta(minutes=max(20,int(operating*rng.uniform(.25,.95))))
        rid=uid()
        runs.append({"run_id":rid,"order_id":oid,"line_id":lid,"start_datetime":st.strftime("%Y-%m-%d %H:%M:%S"),
            "end_datetime":en.strftime("%Y-%m-%d %H:%M:%S"),"planned_production_minutes":planned,"operating_minutes":operating,
            "quantity_produced":produced,"scrap_quantity":scrap,"ideal_cycle_time_seconds":ideal,"staffing_ratio":round(staff_ratio,3)})
        quality.append({"quality_id":uid(),"run_id":rid,"inspected_quantity":produced,"good_quantity":good,"defect_quantity":scrap,
            "defect_reason":py_rng.choice(["Dimensional defect","Surface finish","Assembly error","Material defect","No defect"]),
            "inspection_date":d.date().isoformat()})
        staffing.append({"staffing_id":uid(),"run_id":rid,"line_id":lid,"shift_date":d.date().isoformat(),
            "shift_name":py_rng.choice(["Day","Evening","Night"]),"planned_staff":int(rng.integers(8,17)),
            "actual_staff":max(4,int(rng.integers(7,17)*staff_ratio))})
        if rng.random()<.55:
            eq=py_rng.choice(equip_by_line[lid]); mins=max(5,planned-operating)
            downtime.append({"downtime_id":uid(),"equipment_id":eq,"run_id":rid,
                "downtime_start":(st-pd.Timedelta(minutes=mins)).strftime("%Y-%m-%d %H:%M:%S"),
                "downtime_end":st.strftime("%Y-%m-%d %H:%M:%S"),"downtime_minutes":mins,
                "downtime_reason":py_rng.choices(["Breakdown","Material shortage","Changeover","Maintenance","Power interruption"],[.27,.22,.24,.18,.09])[0]})
orders=pd.DataFrame(orders); runs=pd.DataFrame(runs); quality=pd.DataFrame(quality)
downtime=pd.DataFrame(downtime); staffing=pd.DataFrame(staffing)
feedback=[]
for _,o in orders.sample(frac=.32,random_state=42).iterrows():
    rating=int(rng.choice([1,2,3,4,5],p=[.025,.055,.15,.40,.37]))
    feedback.append({"feedback_id":uid(),"customer_id":o.customer_id,"order_id":o.order_id,
        "feedback_date":(pd.Timestamp(o.order_date)+pd.Timedelta(days=int(rng.integers(2,18)))).date().isoformat(),
        "rating":rating,"feedback_comment":py_rng.choice(["On-time delivery","Good product quality","Packaging needs improvement","Delivery was delayed","Very satisfied","Product met expectations"])})
feedback=pd.DataFrame(feedback)
data={"dim_date":date_dim.drop(columns=["calendar_date"]),"dim_production_line":lines,"dim_equipment":equipment,
      "dim_product":products,"dim_customer":customers,"fact_orders":orders,"fact_production_runs":runs,
      "fact_equipment_downtime":downtime,"fact_quality":quality,"fact_customer_feedback":feedback,"fact_staffing":staffing}
for name,df in data.items(): df.to_csv(OUT/f"{name}.csv",index=False)
print(f"Generated {len(orders):,} orders, {len(runs):,} runs and {len(feedback):,} feedback records.")
