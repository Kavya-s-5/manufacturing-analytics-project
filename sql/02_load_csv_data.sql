USE manufacturing_analytics;
-- Run from MySQL Workbench or mysql client with LOCAL INFILE enabled.
-- Paths below assume you execute from the project root. Adjust absolute paths if required.
LOAD DATA LOCAL INFILE 'data/raw/dim_date.csv' INTO TABLE dim_date
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(date_id,year,quarter,month,month_name,month_start,day_of_week,is_weekend,season);
LOAD DATA LOCAL INFILE 'data/raw/dim_production_line.csv' INTO TABLE dim_production_line
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(line_id,line_name,location,line_type);
LOAD DATA LOCAL INFILE 'data/raw/dim_equipment.csv' INTO TABLE dim_equipment
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(equipment_id,equipment_name,line_id,equipment_type,commissioned_date,ideal_cycle_time_seconds);
LOAD DATA LOCAL INFILE 'data/raw/dim_product.csv' INTO TABLE dim_product
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(product_id,product_name,category);
LOAD DATA LOCAL INFILE 'data/raw/dim_customer.csv' INTO TABLE dim_customer
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(customer_id,customer_name,location,customer_segment);
LOAD DATA LOCAL INFILE 'data/raw/fact_orders.csv' INTO TABLE fact_orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(order_id,product_id,customer_id,order_date,requested_quantity,unit_price,promised_date,order_status);
LOAD DATA LOCAL INFILE 'data/raw/fact_production_runs.csv' INTO TABLE fact_production_runs
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(run_id,order_id,line_id,start_datetime,end_datetime,planned_production_minutes,operating_minutes,quantity_produced,scrap_quantity,ideal_cycle_time_seconds,staffing_ratio);
LOAD DATA LOCAL INFILE 'data/raw/fact_equipment_downtime.csv' INTO TABLE fact_equipment_downtime
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(downtime_id,equipment_id,run_id,downtime_start,downtime_end,downtime_minutes,downtime_reason);
LOAD DATA LOCAL INFILE 'data/raw/fact_quality.csv' INTO TABLE fact_quality
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(quality_id,run_id,inspected_quantity,good_quantity,defect_quantity,defect_reason,inspection_date);
LOAD DATA LOCAL INFILE 'data/raw/fact_customer_feedback.csv' INTO TABLE fact_customer_feedback
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(feedback_id,customer_id,order_id,feedback_date,rating,feedback_comment);
LOAD DATA LOCAL INFILE 'data/raw/fact_staffing.csv' INTO TABLE fact_staffing
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS
(staffing_id,run_id,line_id,shift_date,shift_name,planned_staff,actual_staff);
