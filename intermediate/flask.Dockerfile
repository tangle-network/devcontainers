FROM base-system:latest

RUN pip3 install --no-cache-dir flask flask-restful flask-sqlalchemy

LABEL description="flask intermediate layer"
