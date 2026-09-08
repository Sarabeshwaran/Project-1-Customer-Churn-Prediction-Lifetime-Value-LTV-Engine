from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_home():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_predict_empty_data():
    response = client.post("/predict", json={})

    assert response.status_code == 400
    assert response.json()["detail"] == "Customer data cannot be empty."

def test_predict_invalid_data():
    response = client.post(
        "/predict",
        json={"additionalProp1": {}}
    )

    assert response.status_code == 400
    assert response.json()["detail"] == (
        "No recognized customer features were provided."
    )


def test_predict_batch_invalid_data():
    response = client.post(
        "/predict_batch",
        json=[{"additionalProp1": {}}]
    )

    assert response.status_code == 400
    assert response.json()["detail"] == (
        "No recognized customer features were provided."
    )


def test_predict():
    customer = {
        "gender": 1,
        "SeniorCitizen": 0,
        "Partner": 0,
        "Dependents": 0,
        "tenure": 6,
        "PhoneService": 1,
        "PaperlessBilling": 1,
        "MonthlyCharges": 70.0,
        "MultipleLines_No phone service": 0,
        "MultipleLines_Yes": 0,
        "InternetService_Fiber optic": 1,
        "InternetService_No": 0,
        "OnlineSecurity_No internet service": 0,
        "OnlineSecurity_Yes": 0,
        "OnlineBackup_No internet service": 0,
        "OnlineBackup_Yes": 0,
        "DeviceProtection_No internet service": 0,
        "DeviceProtection_Yes": 0,
        "TechSupport_No internet service": 0,
        "TechSupport_Yes": 0,
        "StreamingTV_No internet service": 0,
        "StreamingTV_Yes": 1,
        "StreamingMovies_No internet service": 0,
        "StreamingMovies_Yes": 1,
        "Contract_One year": 0,
        "Contract_Two year": 0,
        "PaymentMethod_Credit card (automatic)": 0,
        "PaymentMethod_Electronic check": 1,
        "PaymentMethod_Mailed check": 0,
        "avg_monthly_spend": 70.0,
        "charge_diff": 0.0,
        "tenure_group_Mid (1-4yr)": 0,
        "tenure_group_New (0-1yr)": 1
    }

    response = client.post("/predict", json=customer)

    assert response.status_code == 200

    data = response.json()

    assert "churn_probability" in data
    assert "predicted_ltv" in data
    assert 0 <= data["churn_probability"] <= 1
    assert data["predicted_ltv"] >= 0


def test_predict_batch():
    customers = [
        {
            "gender": 1,
            "SeniorCitizen": 0,
            "Partner": 0,
            "Dependents": 0,
            "tenure": 6,
            "PhoneService": 1,
            "PaperlessBilling": 1,
            "MonthlyCharges": 70.0,
            "InternetService_Fiber optic": 1,
            "Contract_One year": 0,
            "Contract_Two year": 0,
            "PaymentMethod_Electronic check": 1,
            "avg_monthly_spend": 70.0,
            "charge_diff": 0.0,
            "tenure_group_Mid (1-4yr)": 0,
            "tenure_group_New (0-1yr)": 1
        },
        {
            "gender": 0,
            "SeniorCitizen": 0,
            "Partner": 1,
            "Dependents": 1,
            "tenure": 48,
            "PhoneService": 1,
            "PaperlessBilling": 1,
            "MonthlyCharges": 65.0,
            "InternetService_Fiber optic": 0,
            "InternetService_No": 0,
            "Contract_One year": 0,
            "Contract_Two year": 1,
            "PaymentMethod_Credit card (automatic)": 1,
            "avg_monthly_spend": 65.0,
            "charge_diff": 0.0,
            "tenure_group_Mid (1-4yr)": 1,
            "tenure_group_New (0-1yr)": 0
        }
    ]

    response = client.post("/predict_batch", json=customers)

    assert response.status_code == 200

    data = response.json()

    assert data["count"] == 2
    assert len(data["predictions"]) == 2
def test_predict_batch_empty_data():
    response = client.post(
        "/predict_batch",
        json=[]
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Customer list cannot be empty."


def test_predict_batch_with_empty_customer():
    response = client.post(
        "/predict_batch",
        json=[{}]
    )

    assert response.status_code == 400
    assert response.json()["detail"] == "Customer data cannot be empty."