from fastapi import FastAPI, HTTPException
import joblib
import pandas as pd

app = FastAPI(
    title="Customer Churn & LTV Prediction API",
    description="API for predicting customer churn probability and lifetime value.",
    version="1.0.0"
)

# Load trained models and feature lists
churn_model = joblib.load("churn_model.pkl")
churn_features = joblib.load("churn_features.pkl")

ltv_model = joblib.load("ltv_model.pkl")
ltv_features = joblib.load("ltv_features.pkl")


@app.get("/")
def home():
    return {
        "message": "Churn & LTV Prediction API is running",
        "status": "healthy"
    }


@app.post("/predict")
def predict(customer_data: dict):

    if not customer_data:
        raise HTTPException(
            status_code=400,
            detail="Customer data cannot be empty."
        )

    if not any(feature in customer_data for feature in churn_features):
        raise HTTPException(
            status_code=400,
            detail="No recognized customer features were provided."
        )

    # Build input for churn model
    churn_df = pd.DataFrame([customer_data]).reindex(
        columns=churn_features,
        fill_value=0
    )

    churn_prob = churn_model.predict_proba(churn_df)[0][1]

    # Build input for LTV model
    ltv_df = pd.DataFrame([customer_data]).reindex(
        columns=ltv_features,
        fill_value=0
    )

    predicted_ltv = ltv_model.predict(ltv_df)[0]

    return {
        "churn_probability": round(float(churn_prob), 4),
        "predicted_ltv": round(float(predicted_ltv), 2)
    }

@app.post("/predict_batch")
def predict_batch(customers: list[dict]):

    if not customers:
        raise HTTPException(
            status_code=400,
            detail="Customer list cannot be empty."
        )

    for customer_data in customers:
        if not customer_data:
            raise HTTPException(
                status_code=400,
                detail="Customer data cannot be empty."
            )

        if not any(feature in customer_data for feature in churn_features):
            raise HTTPException(
                status_code=400,
                detail="No recognized customer features were provided."
            )

    results = []

    try:
        for customer_data in customers:

            # Prepare input for churn model
            churn_df = pd.DataFrame([customer_data]).reindex(
                columns=churn_features,
                fill_value=0
            )

            churn_prob = churn_model.predict_proba(churn_df)[0][1]

            # Prepare input for LTV model
            ltv_df = pd.DataFrame([customer_data]).reindex(
                columns=ltv_features,
                fill_value=0
            )

            predicted_ltv = ltv_model.predict(ltv_df)[0]

            results.append({
                "churn_probability": round(float(churn_prob), 4),
                "predicted_ltv": round(float(predicted_ltv), 2)
            })

        return {
            "count": len(results),
            "predictions": results
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
         
            detail=f"Batch prediction failed: {str(e)}"
        )