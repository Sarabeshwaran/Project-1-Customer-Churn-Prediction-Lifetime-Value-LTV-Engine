# Customer Churn Prediction & Lifetime Value (LTV) Engine

A predictive analytics system for telecom/subscription businesses that identifies customers at risk of churning and estimates their Customer Lifetime Value (LTV), helping marketing teams prioritize retention efforts.

**Status:** All 4 weeks complete — data pipeline, modeling, LTV, API, dashboards, and Docker containerization.


## Tech Stack

- **Languages:** Python, SQL
- **Data Storage:** PostgreSQL, SQLAlchemy
- **ML/Analysis:** Pandas, Scikit-Learn, XGBoost, SHAP
- **API:** FastAPI
- **Dashboards:** Metabase (via Docker)
- **Dataset:** [Telco Customer Churn Dataset](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) (7,043 customers, 21 raw features)

---

## Progress by Week

### ✅ Week 1 — Data Ingestion & EDA
- Loaded the Telco dataset into a PostgreSQL database (`telco_churn`) via SQLAlchemy
- Fixed a hidden data quality issue: `TotalCharges` was stored as text and had 11 blank values for brand-new customers (tenure = 0); converted to numeric and filled with 0
- Explored churn patterns:
  - **27% overall churn rate** (moderately imbalanced — accuracy alone is a misleading metric)
  - **Contract type is the strongest single driver**: month-to-month customers churn at ~42%, one-year at ~11%, two-year at under 3%
  - **Tenure matters**: churned customers have a median tenure of ~10 months vs. ~38 months for retained customers
- One-hot encoded categorical variables into a model-ready table (`customers_encoded`)

**Notebooks:** `load_data.ipynb`, `eda_telco_churn.ipynb`

### ✅ Week 2 — Feature Engineering & Predictive Modeling
- Engineered new features: `avg_monthly_spend`, `charge_diff` (current vs. historical spend), and `tenure_group` buckets
- Trained and compared three classifiers: Logistic Regression, Random Forest, XGBoost
- Addressed class imbalance using `scale_pos_weight` — improved churn-class recall from ~51% to **68%** (catching more actual churners), a deliberate trade-off against precision, appropriate for a retention use case where missing a churner is costlier than a false alarm
- Applied **SHAP** for explainability:
  - Global driver ranking (tenure, contract length, monthly spend, fiber internet, payment method)
  - Individual prediction breakdowns (waterfall plots) showing exactly why a given customer is flagged as high/low risk

**Notebook:** `model_training.ipynb`

**Final model:** XGBoost (class-balanced) — Precision 0.53 / Recall 0.68 / F1 0.60 on churn class

### ✅ Week 3 — LTV Calculation & API Development
- Built an LTV regression target (`MonthlyCharges × tenure`) and trained a Random Forest regressor
- **Caught and fixed a data leakage issue**: the first model version scored an unrealistic R² of 0.9998 because `tenure`/`MonthlyCharges` were both inputs and (via the formula) the answer. Removing them and relying on engineered features instead produced a trustworthy **R² of 0.95** — meaning the model can estimate LTV for a *brand-new* customer using only their profile (contract, services, payment method), not billing history
- Built a **FastAPI service** (`main.py`) with:
  - `POST /predict` — single customer churn + LTV prediction
  - `POST /predict_batch` — batch scoring for multiple customers at once
  - Interactive docs at `/docs`
- Saved trained models with `joblib` for the API to load without retraining

#### Batch Prediction API Validation

The `/predict/batch` endpoint supports predicting churn probability and Customer Lifetime Value (LTV) for multiple customers in a single request.

- Accepts a list of customer data objects
- Returns churn probability and predicted LTV for each customer
- Handles an empty customer list with the error message: `Customer list cannot be empty`

**Notebook:** `ltv_model.ipynb` · **API:** `main.py`

### ✅ Week 4 — Visualization & Deployment
- Connected **Metabase** (via Docker) to the PostgreSQL database
- Scored all 7,043 customers using the saved churn and LTV models, saving results (`churn_probability`, `predicted_ltv`) to a new `customer_predictions` table — closing the loop between the trained models and the dashboards
- Built four dashboard charts, combined into a single Metabase Dashboard:
  1. **Churn by Contract Type** — confirms month-to-month contracts churn at ~42% vs. under 3% for two-year contracts
  2. **Average Monthly Charges by Tenure & Churn** — churned customers pay more per month than retained customers, at every tenure stage
  3. **Revenue by Contract Type** — two-year contracts generate the most total revenue (~$6M); month-to-month still contributes ~$5.2M despite high churn
  4. **Churn Risk vs. Predicted LTV** (scatter, all 7,043 customers) — the headline chart, directly identifying the priority segment (high value + high risk) for targeted retention spend
- **Containerized the FastAPI service with Docker** (`Dockerfile`, `.dockerignore`, `requirements.txt`) — the API now runs as a portable, self-contained service, independent of any local Python setup

See `docs/` for dashboard screenshots.
---

## How to Run This Project

```bash
# 1. Set up virtual environment
python -m venv venv
venv\Scripts\activate          # Windows
pip install -r requirements.txt

# 2. Ensure PostgreSQL is running with the telco_churn database populated
#    (see load_data.ipynb to (re)load the raw dataset)

# 3. Run the API
uvicorn main:app --reload
# → http://127.0.0.1:8000/docs

# 4. Run dashboards (Metabase via Docker)
docker run -d -p 3000:3000 --name metabase metabase/metabase
# → http://localhost:3000
# Connect with: Host=host.docker.internal, Port=5432, DB=telco_churn
```

---

## Key Findings (Business Summary)

The highest churn-risk profile: **new customers, on month-to-month contracts, with high monthly charges, on fiber internet, paying by electronic check.** This is an actionable segment for targeted retention campaigns. Two-year contract customers are the company's most stable base and churn at under 3%.

---

## Repository Structure

```
├── load_data.ipynb          # Week 1: raw data → PostgreSQL
├── eda_telco_churn.ipynb    # Week 1: EDA, cleaning, encoding
├── model_training.ipynb     # Week 2: churn classification models + SHAP
├── ltv_model.ipynb          # Week 3: LTV regression model
├── main.py                  # Week 3: FastAPI prediction service
├── *.pkl                    # Saved trained models & feature lists
├── .gitignore
├── generate_predictions.ipynb  # Week 4: score all customers, save to customer_predictions
├── Dockerfile                # Week 4: containerize the API
├── .dockerignore
├── docs/                     # dashboard screenshots
└── README.md
```
