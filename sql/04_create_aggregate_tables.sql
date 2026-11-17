USE manufacturing_analytics;

CREATE TABLE IF NOT EXISTS agg_oee_daily AS
SELECT
    production_date, line_id,
    COUNT(*) AS production_runs,
    SUM(planned_production_minutes) AS planned_minutes,
    SUM(operating_minutes) AS operating_minutes,
    SUM(quantity_produced) AS total_units,
    SUM(good_quantity) AS good_units,
    SUM(scrap_quantity) AS scrap_units,
    SUM(operating_minutes)/NULLIF(SUM(planned_production_minutes),0) AS availability_ratio,
    SUM(quantity_produced*ideal_cycle_time_seconds)/
      NULLIF(SUM(operating_minutes)*60.0,0) AS performance_ratio,
    SUM(good_quantity)/NULLIF(SUM(quantity_produced),0) AS quality_ratio,
    (SUM(operating_minutes)/NULLIF(SUM(planned_production_minutes),0)) *
    (SUM(quantity_produced*ideal_cycle_time_seconds)/NULLIF(SUM(operating_minutes)*60.0,0)) *
    (SUM(good_quantity)/NULLIF(SUM(quantity_produced),0)) AS oee_ratio
FROM vw_run_kpis
GROUP BY production_date,line_id;

CREATE TABLE IF NOT EXISTS agg_production_monthly AS
SELECT DATE_FORMAT(r.production_date,'%Y-%m-01') AS month_start,
       l.line_name,p.product_name,p.category,
       COUNT(*) AS production_runs,
       SUM(r.quantity_produced) AS total_units,
       SUM(r.good_quantity) AS good_units,
       SUM(r.scrap_quantity) AS scrap_units,
       100.0*SUM(r.good_quantity)/NULLIF(SUM(r.quantity_produced),0) AS yield_pct,
       100.0*SUM(r.scrap_quantity)/NULLIF(SUM(r.quantity_produced),0) AS scrap_rate_pct,
       AVG(r.cycle_time_minutes) AS avg_cycle_time_minutes,
       100.0*AVG(r.oee_ratio) AS avg_oee_pct
FROM vw_run_kpis r
JOIN fact_orders o ON o.order_id=r.order_id
JOIN dim_product p ON p.product_id=o.product_id
JOIN dim_production_line l ON l.line_id=r.line_id
GROUP BY DATE_FORMAT(r.production_date,'%Y-%m-01'),l.line_name,p.product_name,p.category;

CREATE TABLE IF NOT EXISTS agg_customer_satisfaction_monthly AS
SELECT DATE_FORMAT(f.feedback_date,'%Y-%m-01') AS month_start,
       c.customer_segment,c.location,
       COUNT(*) AS feedback_count,
       SUM(CASE WHEN f.rating>=4 THEN 1 ELSE 0 END) AS positive_feedback,
       100.0*SUM(CASE WHEN f.rating>=4 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS satisfaction_index
FROM fact_customer_feedback f
JOIN dim_customer c ON c.customer_id=f.customer_id
GROUP BY DATE_FORMAT(f.feedback_date,'%Y-%m-01'),c.customer_segment,c.location;

CREATE TABLE IF NOT EXISTS agg_downtime_monthly AS
SELECT DATE_FORMAT(d.downtime_start,'%Y-%m-01') AS month_start,
       e.equipment_name,e.equipment_type,l.line_name,d.downtime_reason,
       COUNT(*) AS downtime_events,SUM(d.downtime_minutes) AS downtime_minutes
FROM fact_equipment_downtime d
JOIN dim_equipment e ON e.equipment_id=d.equipment_id
JOIN dim_production_line l ON l.line_id=e.line_id
GROUP BY DATE_FORMAT(d.downtime_start,'%Y-%m-01'),e.equipment_name,e.equipment_type,l.line_name,d.downtime_reason;

CREATE TABLE IF NOT EXISTS agg_staffing_monthly AS
SELECT DATE_FORMAT(s.shift_date,'%Y-%m-01') AS month_start,
       l.line_name,s.shift_name,
       SUM(s.planned_staff) AS planned_staff_shifts,
       SUM(s.actual_staff) AS actual_staff_shifts,
       100.0*SUM(s.actual_staff)/NULLIF(SUM(s.planned_staff),0) AS staffing_coverage_pct
FROM fact_staffing s
JOIN dim_production_line l ON l.line_id=s.line_id
GROUP BY DATE_FORMAT(s.shift_date,'%Y-%m-01'),l.line_name,s.shift_name;
