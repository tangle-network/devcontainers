FROM base-system:latest

USER root
RUN npm install -g jest @types/jest ts-jest
USER project

LABEL description="jest intermediate layer"
