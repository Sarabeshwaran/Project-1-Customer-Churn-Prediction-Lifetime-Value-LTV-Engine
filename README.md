# Customer Churn Prediction & Lifetime Value (LTV) Engine

A predictive analytics system for telecom/subscription businesses that identifies customers at risk of churning and estimates their Customer Lifetime Value (LTV), helping marketing teams prioritize retention efforts.

**Status:** All 4 weeks complete — data pipeline, modeling, LTV, API, dashboards, testing, and Docker deployment.

---

## Tech Stack

- **Languages:** Python, SQL
- **Data Storage:** PostgreSQL, SQLAlchemy
- **ML/Analysis:** Pandas, Scikit-Learn, XGBoost, SHAP
- **API:** FastAPI
- **Testing:** Pytest
- **CI/CD:** GitHub Actions
- **Dashboards:** Metabase
- **Containerization:** Docker
- **Dataset:** [Telco Customer Churn Dataset](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)
  - 7,043 customers
  - 21 raw features

---

## Progress by Week

### ✅ Week 1 — Data Ingestion & EDA

- Loaded the Telco dataset into a PostgreSQL database (`telco_churn`) using SQLAlchemy.
- Fixed a data quality issue where `TotalCharges` was stored as text.
- Identified 11 blank `TotalCharges` values for brand-new customers with tenure = 0 and converted them to numeric values, filling blanks with 0.
- Explored major churn patterns:
  - **27% overall churn rate**
  - Month-to-month customers churn at approximately **42%**
  - One-year contract customers churn at approximately **11%**
  - Two-year contract customers churn at under **3%**
  - Churned customers have a median tenure of approximately **10 months**, compared with approximately **38 months** for retained customers.
- One-hot encoded categorical variables into a model-ready table (`customers_encoded`).

**Notebooks:**
- `load_data.ipynb`
- `eda_telco_churn.ipynb`

---

### ✅ Week 2 — Feature Engineering & Predictive Modeling

- Engineered additional features:
  - `avg_monthly_spend`
  - `charge_diff`
  - `tenure_group`
- Trained and compared:
  - Logistic Regression
  - Random Forest
  - XGBoost
- Addressed class imbalance using `scale_pos_weight`.
- Improved churn-class recall from approximately **51% to 68%**, prioritizing the detection of potential churners.
- Applied **SHAP** for model explainability:
  - Global feature importance
  - Individual prediction explanations
  - Waterfall plots for customer-level risk analysis

**Final churn model:** XGBoost with class balancing

**Churn-class performance:**
- Precision: **0.53**
- Recall: **0.68**
- F1 Score: **0.60**

**Notebook:** `model_training.ipynb`

---

### ✅ Week 3 — LTV Calculation & API Development

#### LTV Modeling

- Built an LTV regression target using:

  `MonthlyCharges × tenure`

- Trained a Random Forest regression model.
- Identified and fixed a data leakage issue where `tenure` and `MonthlyCharges` were directly contributing to the target.
- The initial model produced an unrealistic **R² of 0.9998**.
- After removing the leakage-prone inputs and using engineered customer profile features, the model achieved a more trustworthy **R² of approximately 0.95**.
- The resulting model can estimate LTV for a new customer using profile information rather than historical billing data.

**Notebook:** `ltv_model.ipynb`

---

#### FastAPI Prediction Service

Built a FastAPI service in `main.py` that provides:

| Endpoint | Method | Purpose |
|---|---|---|
| `/` | GET | API health check |
| `/predict` | POST | Predict churn probability and LTV for one customer |
| `/predict_batch` | POST | Predict churn probability and LTV for multiple customers |
| `/docs` | GET | Interactive Swagger API documentation |

### API Version

**1.0.0**

### Example Health Check

```http
GET /