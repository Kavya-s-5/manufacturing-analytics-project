CREATE DATABASE IF NOT EXISTS manufacturing_analytics;
USE manufacturing_analytics;

CREATE TABLE dim_date (
  date_id INT PRIMARY KEY,
  year SMALLINT NOT NULL, quarter TINYINT NOT NULL, month TINYINT NOT NULL,
  month_name VARCHAR(15) NOT NULL, month_start DATE NOT NULL,
  day_of_week VARCHAR(12) NOT NULL, is_weekend BOOLEAN NOT NULL, season VARCHAR(20) NOT NULL
);

CREATE TABLE dim_production_line (
  line_id CHAR(36) PRIMARY KEY, line_name VARCHAR(100) NOT NULL,
  location VARCHAR(100) NOT NULL, line_type VARCHAR(50) NOT NULL
);

CREATE TABLE dim_equipment (
  equipment_id CHAR(36) PRIMARY KEY, equipment_name VARCHAR(100) NOT NULL,
  line_id CHAR(36) NOT NULL, equipment_type VARCHAR(60) NOT NULL,
  commissioned_date DATE NOT NULL, ideal_cycle_time_seconds DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_equipment_line FOREIGN KEY (line_id) REFERENCES dim_production_line(line_id)
);

CREATE TABLE dim_product (
  product_id CHAR(36) PRIMARY KEY, product_name VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL
);

CREATE TABLE dim_customer (
  customer_id CHAR(36) PRIMARY KEY, customer_name VARCHAR(120) NOT NULL,
  location VARCHAR(80) NOT NULL, customer_segment VARCHAR(40) NOT NULL
);

CREATE TABLE fact_orders (
  order_id CHAR(36) PRIMARY KEY, product_id CHAR(36) NOT NULL,
  customer_id CHAR(36) NOT NULL, order_date DATE NOT NULL,
  requested_quantity INT NOT NULL, unit_price DECIMAL(12,2) NOT NULL,
  promised_date DATE NOT NULL, order_status VARCHAR(30) NOT NULL,
  CONSTRAINT fk_order_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  INDEX idx_orders_date (order_date)
);

CREATE TABLE fact_production_runs (
  run_id CHAR(36) PRIMARY KEY, order_id CHAR(36) NOT NULL,
  line_id CHAR(36) NOT NULL, start_datetime DATETIME NOT NULL,
  end_datetime DATETIME NOT NULL, planned_production_minutes INT NOT NULL,
  operating_minutes INT NOT NULL, quantity_produced INT NOT NULL,
  scrap_quantity INT NOT NULL, ideal_cycle_time_seconds DECIMAL(10,2) NOT NULL,
  staffing_ratio DECIMAL(5,3) NOT NULL,
  CONSTRAINT fk_run_order FOREIGN KEY (order_id) REFERENCES fact_orders(order_id),
  CONSTRAINT fk_run_line FOREIGN KEY (line_id) REFERENCES dim_production_line(line_id),
  INDEX idx_runs_start (start_datetime)
);

CREATE TABLE fact_equipment_downtime (
  downtime_id CHAR(36) PRIMARY KEY, equipment_id CHAR(36) NOT NULL,
  run_id CHAR(36) NOT NULL, downtime_start DATETIME NOT NULL,
  downtime_end DATETIME NOT NULL, downtime_minutes INT NOT NULL,
  downtime_reason VARCHAR(60) NOT NULL,
  CONSTRAINT fk_downtime_equipment FOREIGN KEY (equipment_id) REFERENCES dim_equipment(equipment_id),
  CONSTRAINT fk_downtime_run FOREIGN KEY (run_id) REFERENCES fact_production_runs(run_id)
);

CREATE TABLE fact_quality (
  quality_id CHAR(36) PRIMARY KEY, run_id CHAR(36) NOT NULL,
  inspected_quantity INT NOT NULL, good_quantity INT NOT NULL,
  defect_quantity INT NOT NULL, defect_reason VARCHAR(60) NOT NULL,
  inspection_date DATE NOT NULL,
  CONSTRAINT fk_quality_run FOREIGN KEY (run_id) REFERENCES fact_production_runs(run_id)
);

CREATE TABLE fact_customer_feedback (
  feedback_id CHAR(36) PRIMARY KEY, customer_id CHAR(36) NOT NULL,
  order_id CHAR(36) NOT NULL, feedback_date DATE NOT NULL,
  rating TINYINT NOT NULL, feedback_comment VARCHAR(255),
  CONSTRAINT fk_feedback_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  CONSTRAINT fk_feedback_order FOREIGN KEY (order_id) REFERENCES fact_orders(order_id),
  CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE fact_staffing (
  staffing_id CHAR(36) PRIMARY KEY, run_id CHAR(36) NOT NULL,
  line_id CHAR(36) NOT NULL, shift_date DATE NOT NULL,
  shift_name VARCHAR(20) NOT NULL, planned_staff INT NOT NULL,
  actual_staff INT NOT NULL,
  CONSTRAINT fk_staff_run FOREIGN KEY (run_id) REFERENCES fact_production_runs(run_id),
  CONSTRAINT fk_staff_line FOREIGN KEY (line_id) REFERENCES dim_production_line(line_id)
);
