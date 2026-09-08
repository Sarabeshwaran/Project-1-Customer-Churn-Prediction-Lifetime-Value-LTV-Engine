FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Prevent Python from creating .pyc files
# and enable immediate log output
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install Python dependencies
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY main.py .
COPY churn_model.pkl .
COPY churn_features.pkl .
COPY ltv_model.pkl .
COPY ltv_features.pkl .

# Expose FastAPI port
EXPOSE 8000

# Check whether the API is responding
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/', timeout=3)"


# Start FastAPI application
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]