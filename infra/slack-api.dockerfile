FROM base-system:latest

# User commands (pip, go install, etc.)
RUN pip install slack_sdk && \
    pip install slack_sdk[optional] && \
    pip3 install proxy.py

LABEL description="slack-api infrastructure layer"
