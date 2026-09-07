# Customer Prediction Generation

## Overview

The `generate_predictions.ipynb` notebook generates customer-level predictions using the trained Churn Prediction and Lifetime Value (LTV) models.

## Models Used

The prediction process uses:

- `churn_model.pkl` - Predicts customer churn probability.
- `churn_features.pkl` - Contains the features required by the churn model.
- `ltv_model.pkl` - Predicts the customer Lifetime Value.
- `ltv_features.pkl` - Contains the features required by the LTV model.

## Input Data

The prediction process uses customer data from:

```text
Telco-Customer-Churn.csv

## Verification

The generated predictions can be verified by querying the database:

```sql
SELECT COUNT(*)
FROM customer_predictions;