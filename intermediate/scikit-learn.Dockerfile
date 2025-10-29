FROM base-system:latest

RUN pip3 install --no-cache-dir scikit-learn joblib

LABEL description="scikit-learn intermediate layer"
