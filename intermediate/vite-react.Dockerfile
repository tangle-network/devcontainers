FROM base-system:latest

USER root
RUN npm install -g vite react react-dom @vitejs/plugin-react
USER project

LABEL description="vite-react intermediate layer"
