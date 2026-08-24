from fastapi import FastAPI
import joblib
import pandas as pd
from typing import List

app = FastAPI()

churn_model = joblib.load("churn_model.pkl")
churn_features = joblib.load("churn_features.pkl")

ltv_model = joblib.load("ltv_model.pkl")
ltv_features = joblib.load("ltv_features.pkl")

@app.get("/")
def home():
    return {"message": "Churn & LTV Prediction API is running"}

@app.post("/predict")
def predict(customer_data: dict):
    # Build input for churn model (needs tenure + MonthlyCharges)
    churn_df = pd.DataFrame([customer_data]).reindex(columns=churn_features, fill_value=0)
    churn_prob = churn_model.predict_proba(churn_df)[0][1]

    # Build input for LTV model (without tenure + MonthlyCharges)
    ltv_df = pd.DataFrame([customer_data]).reindex(columns=ltv_features, fill_value=0)
    predicted_ltv = ltv_model.predict(ltv_df)[0]

    return {
        "churn_probability": round(float(churn_prob), 4),
        "predicted_ltv": round(float(predicted_ltv), 2)
    }

@app.post("/predict_batch")
def predict_batch(customers: List[dict]):
    results = []
    for customer_data in customers:
        churn_df = pd.DataFrame([customer_data]).reindex(columns=churn_features, fill_value=0)
        churn_prob = churn_model.predict_proba(churn_df)[0][1]

        ltv_df = pd.DataFrame([customer_data]).reindex(columns=ltv_features, fill_value=0)
        predicted_ltv = ltv_model.predict(ltv_df)[0]

        results.append({
            "churn_probability": round(float(churn_prob), 4),
            "predicted_ltv": round(float(predicted_ltv), 2)
        })
    return {"predictions": results}