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