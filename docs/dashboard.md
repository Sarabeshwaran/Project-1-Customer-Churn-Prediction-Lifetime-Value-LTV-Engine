# Customer Churn & Revenue Dashboard

This dashboard provides business-focused insights into customer churn,
contract behavior, tenure, and revenue patterns.

## Dashboard Visualizations

### 1. Churn by Contract Type

![Churn by Contract](churn_by_contract_dashboard.png)

This visualization compares customer churn across contract types.
Month-to-month customers represent the highest-risk contract segment,
while longer-term contracts show substantially lower churn.

### 2. Charges by Tenure and Churn

![Charges by Tenure and Churn](charges_by_tenure_churn.png)

This visualization examines the relationship between customer tenure,
monthly charges, and churn behavior.

It helps identify whether newer customers with higher charges represent
a higher-risk retention segment.

### 3. Revenue by Contract Type

![Revenue by Contract Type](revenue_by_contract_type.png)

This visualization shows revenue patterns across different contract
types and helps identify the contribution of each contract segment.

## Business Use

The dashboard can help marketing and retention teams:

- Identify high-churn customer segments
- Compare churn across contract types
- Understand the relationship between tenure and customer charges
- Analyze revenue contribution by contract type
- Prioritize customer retention strategies

## Dashboard Data

The visualizations are based on the Telco Customer Churn dataset
containing 7,043 customer records.

The analytical SQL queries used to support these dashboard metrics are
available in:

`../sql/dashboard_queries.sql`