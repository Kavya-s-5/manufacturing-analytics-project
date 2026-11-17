# Manufacturing Analytics – Inference Report

## 1. Executive summary
This report analyzes a synthetic manufacturing dataset covering 1 January 2022 to 31 December 2026. It contains 7,166 customer orders, 7,166 production runs, 3,907 downtime events and 2,293 customer feedback responses. All records are artificial and intended to demonstrate analytics methods, not describe a real manufacturer.

## 2. KPI snapshot
| KPI | Result |
|---|---:|
| Average run-level OEE | 36.05% |
| Production yield | 95.91% |
| Scrap rate | 4.09% |
| Average cycle time | 228.67 minutes |
| Customer satisfaction index | 77.54% |

OEE = availability × performance × quality. Yield = good units / total produced. Scrap rate = scrap units / total produced. Cycle time = run end minus run start. Satisfaction = ratings of 4 or 5 divided by all feedback responses.

## 3. Seasonal demand pattern
The generator applies a rising seasonal demand index toward October–December, with December assigned the strongest demand multiplier. In the realized dataset, Nov has the largest total produced volume among calendar months. This is a designed seasonal effect, not an independently discovered market fact. A real analysis should compare monthly orders, backlog, capacity utilization and shipped units to confirm whether demand and production move together.

## 4. Holiday shutdown effect
The generator reduces planned production minutes for weekends and the year-end / New Year holiday window. This should be visible as lower daily planned minutes and fewer runs on affected dates. Compare operating minutes with planned production minutes; do not treat a facility shutdown outside planned production time as equipment downtime.

## 5. Supply chain disruption scenarios
Four stress windows were deliberately introduced: July 2023, August 2024, June 2025 and September 2026. The generator reduces order arrival intensity and applies higher downtime and lower performance / quality assumptions in those windows. Mean run-level OEE in stress windows is 33.04% versus 36.21% in other months. Scrap rate is 6.21% versus 3.99%. These are programmed scenario effects and must be labeled as synthetic assumptions in the dashboard.

## 6. Staffing adjustments
The generator varies staffing coverage by season and applies a small performance penalty during peak periods to represent onboarding and workload pressure. Analyze staffing coverage alongside OEE, yield and cycle time by month and line. Correlation alone does not establish causation; a real study would control for product mix, machine age, shift and demand intensity.

## 7. Customer satisfaction
Feedback is sampled for approximately 32% of orders. Positive feedback is defined as a rating of 4 or 5. Overall satisfaction is 77.54%. This is a survey-response metric, not the percentage of all customers who are satisfied. Monitor response bias and monthly sample sizes.

## 8. Recommendations
1. Review the highest downtime reasons and equipment by month; prioritize recurring breakdowns and material shortages.
2. Compare peak-season scrap rate with non-peak periods and inspect defect reasons.
3. Track OEE using planned production time that excludes non-production shutdowns.
4. Monitor staffing coverage by shift and line during peak demand months.
5. Display satisfaction with response counts and avoid over-interpreting months with few responses.
6. Replace synthetic records with validated MES, ERP, CMMS and customer survey data in a production deployment.

## 9. Limitations
- All data and names are synthetic.
- One production run is linked to one order for teaching simplicity.
- Downtime events are a partial event log and are not used as the OEE availability denominator; planned and operating minutes on the run fact are authoritative.
- Cycle time is elapsed run duration, not per-unit cycle time.
- Ratings 4–5 are treated as positive by explicit project convention.
