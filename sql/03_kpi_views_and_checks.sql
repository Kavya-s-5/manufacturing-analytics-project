USE manufacturing_analytics;

-- KPI definitions:
-- Availability = operating minutes / planned production minutes
-- Performance = (actual units * ideal cycle seconds) / (operating minutes * 60)
-- Quality = good units / total units
-- OEE = Availability * Performance * Quality
-- Yield = good units / total units
-- Scrap rate = scrap units / total units
-- Cycle time = elapsed minutes from run start to run end
-- Customer satisfaction = responses rated 4 or 5 / all valid responses

CREATE OR REPLACE VIEW vw_run_kpis AS
SELECT
    r.run_id, r.order_id, r.line_id, DATE(r.start_datetime) AS production_date,
    r.planned_production_minutes, r.operating_minutes,
    r.quantity_produced, r.scrap_quantity,
    COALESCE(q.good_quantity, r.quantity_produced-r.scrap_quantity) AS good_quantity,
    r.ideal_cycle_time_seconds,
    TIMESTAMPDIFF(SECOND,r.start_datetime,r.end_datetime)/60.0 AS cycle_time_minutes,
    r.operating_minutes / NULLIF(r.planned_production_minutes,0) AS availability_ratio,
    (r.quantity_produced*r.ideal_cycle_time_seconds) /
      NULLIF(r.operating_minutes*60.0,0) AS performance_ratio,
    COALESCE(q.good_quantity, r.quantity_produced-r.scrap_quantity) /
      NULLIF(r.quantity_produced,0) AS quality_ratio,
    (r.operating_minutes / NULLIF(r.planned_production_minutes,0)) *
    ((r.quantity_produced*r.ideal_cycle_time_seconds) / NULLIF(r.operating_minutes*60.0,0)) *
    (COALESCE(q.good_quantity, r.quantity_produced-r.scrap_quantity) / NULLIF(r.quantity_produced,0)) AS oee_ratio
FROM fact_production_runs r
LEFT JOIN fact_quality q ON q.run_id = r.run_id;

CREATE OR REPLACE VIEW vw_customer_satisfaction AS
SELECT
    DATE_FORMAT(feedback_date,'%Y-%m-01') AS month_start,
    COUNT(*) AS feedback_count,
    SUM(CASE WHEN rating >= 4 THEN 1 ELSE 0 END) AS positive_feedback,
    100.0*SUM(CASE WHEN rating >= 4 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS satisfaction_index
FROM fact_customer_feedback
GROUP BY DATE_FORMAT(feedback_date,'%Y-%m-01');

-- Quick KPI checks
SELECT ROUND(100*AVG(oee_ratio),2) AS average_oee_pct FROM vw_run_kpis;
SELECT ROUND(100*SUM(good_quantity)/NULLIF(SUM(quantity_produced),0),2) AS production_yield_pct
FROM vw_run_kpis;
SELECT ROUND(100*SUM(scrap_quantity)/NULLIF(SUM(quantity_produced),0),2) AS scrap_rate_pct
FROM vw_run_kpis;
SELECT ROUND(AVG(cycle_time_minutes),2) AS average_cycle_time_minutes FROM vw_run_kpis;
SELECT ROUND(100*AVG(rating>=4),2) AS customer_satisfaction_pct FROM fact_customer_feedback;
