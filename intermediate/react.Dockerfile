FROM base-system:latest

USER root
RUN npm install -g react react-dom @types/react @types/react-dom
USER project

LABEL description="react intermediate layer"
