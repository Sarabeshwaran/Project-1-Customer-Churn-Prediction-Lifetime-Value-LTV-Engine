-- ============================================================
-- Customer Churn & LTV Engine - Dashboard Queries
-- ============================================================

-- 1. Overall Customer KPIs
-- Total customers, churned customers, retained customers,
-- and overall churn rate.

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN "Churn" = 'No' THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers;


-- 2. Churn Rate by Contract
-- Useful for identifying high-risk contract segments.

SELECT
    "Contract" AS contract_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
GROUP BY "Contract"
ORDER BY churn_rate_percent DESC;


-- 3. Churn Rate by Tenure Group
-- Groups customers based on their tenure.

SELECT
    CASE
        WHEN tenure <= 12 THEN 'New (0-1yr)'
        WHEN tenure <= 48 THEN 'Mid (1-4yr)'
        ELSE 'Long-term (4+yr)'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
GROUP BY
    CASE
        WHEN tenure <= 12 THEN 'New (0-1yr)'
        WHEN tenure <= 48 THEN 'Mid (1-4yr)'
        ELSE 'Long-term (4+yr)'
    END
ORDER BY churn_rate_percent DESC;


-- 4. Churn Rate by Payment Method

SELECT
    "PaymentMethod" AS payment_method,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
GROUP BY "PaymentMethod"
ORDER BY churn_rate_percent DESC;


-- 5. Churn Rate by Internet Service

SELECT
    "InternetService" AS internet_service,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
GROUP BY "InternetService"
ORDER BY churn_rate_percent DESC;


-- 6. Average Monthly Charges by Churn Status

SELECT
    "Churn" AS churn_status,
    COUNT(*) AS customers,
    ROUND(AVG("MonthlyCharges"), 2) AS avg_monthly_charges,
    ROUND(AVG(tenure), 2) AS avg_tenure
FROM customers
GROUP BY "Churn"
ORDER BY "Churn";


-- 7. High-Risk Customer Segment
-- New customers with month-to-month contracts,
-- fiber internet and electronic-check payments.

SELECT
    COUNT(*) AS high_risk_customers,
    ROUND(AVG("MonthlyCharges"), 2) AS avg_monthly_charges,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
WHERE tenure <= 12
  AND "Contract" = 'Month-to-month'
  AND "InternetService" = 'Fiber optic'
  AND "PaymentMethod" = 'Electronic check';


-- 8. Churn by Contract and Internet Service
-- Useful for a dashboard heatmap/table.

SELECT
    "Contract" AS contract_type,
    "InternetService" AS internet_service,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(
        100.0 * SUM(CASE WHEN "Churn" = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS churn_rate_percent
FROM customers
GROUP BY "Contract", "InternetService"
ORDER BY churn_rate_percent DESC;

-- ============================================================
-- Prediction-Based Dashboard Queries
-- Source: customer_predictions
-- ============================================================

-- 9. Overall Prediction KPIs
-- Average predicted churn probability and average predicted LTV.

SELECT
    COUNT(*) AS total_predictions,
    ROUND(AVG(churn_probability)::numeric, 4) AS avg_churn_probability,
    ROUND(AVG(predicted_ltv)::numeric, 2) AS avg_predicted_ltv,
    ROUND(SUM(predicted_ltv)::numeric, 2) AS total_predicted_ltv
FROM customer_predictions;


-- 10. Predicted LTV by Actual Churn Status
-- Compares predicted customer value between churned and retained customers.

SELECT
    actual_churn,
    COUNT(*) AS customers,
    ROUND(AVG(predicted_ltv)::numeric, 2) AS avg_predicted_ltv,
    ROUND(AVG(churn_probability)::numeric, 4) AS avg_churn_probability
FROM customer_predictions
GROUP BY actual_churn
ORDER BY avg_predicted_ltv DESC;


-- 11. High-Risk Customers
-- Customers with churn probability of 70% or higher.

SELECT
    customerID,
    ROUND(churn_probability::numeric, 4) AS churn_probability,
    ROUND(predicted_ltv::numeric, 2) AS predicted_ltv,
    actual_churn
FROM customer_predictions
WHERE churn_probability >= 0.70
ORDER BY churn_probability DESC;


-- 12. High-Risk, High-Value Customers
-- Customers who have both high churn risk and high predicted LTV.
-- These customers are strong candidates for targeted retention.

SELECT
    customerID,
    ROUND(churn_probability::numeric, 4) AS churn_probability,
    ROUND(predicted_ltv::numeric, 2) AS predicted_ltv,
    actual_churn
FROM customer_predictions
WHERE churn_probability >= 0.70
  AND predicted_ltv >= (
      SELECT AVG(predicted_ltv)
      FROM customer_predictions
  )
ORDER BY predicted_ltv DESC, churn_probability DESC;


-- 13. Prediction Performance by Actual Churn
-- Shows whether predicted churn probability differs
-- between customers who actually churned and those retained.

SELECT
    actual_churn,
    COUNT(*) AS customers,
    ROUND(AVG(churn_probability)::numeric, 4) AS avg_predicted_churn_probability,
    ROUND(MIN(churn_probability)::numeric, 4) AS min_churn_probability,
    ROUND(MAX(churn_probability)::numeric, 4) AS max_churn_probability
FROM customer_predictions
GROUP BY actual_churn
ORDER BY actual_churn;


-- 14. Customer Value and Churn Risk Segments
-- Creates four actionable business segments.

SELECT
    CASE
        WHEN churn_probability >= 0.70
             AND predicted_ltv >= (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'High Risk / High Value'

        WHEN churn_probability >= 0.70
             AND predicted_ltv < (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'High Risk / Low Value'

        WHEN churn_probability < 0.70
             AND predicted_ltv >= (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'Low Risk / High Value'

        ELSE 'Low Risk / Low Value'
    END AS customer_segment,

    COUNT(*) AS customers,
    ROUND(AVG(churn_probability)::numeric, 4) AS avg_churn_probability,
    ROUND(AVG(predicted_ltv)::numeric, 2) AS avg_predicted_ltv

FROM customer_predictions

GROUP BY
    CASE
        WHEN churn_probability >= 0.70
             AND predicted_ltv >= (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'High Risk / High Value'

        WHEN churn_probability >= 0.70
             AND predicted_ltv < (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'High Risk / Low Value'

        WHEN churn_probability < 0.70
             AND predicted_ltv >= (
                 SELECT AVG(predicted_ltv)
                 FROM customer_predictions
             )
            THEN 'Low Risk / High Value'

        ELSE 'Low Risk / Low Value'
    END

ORDER BY avg_predicted_ltv DESC;