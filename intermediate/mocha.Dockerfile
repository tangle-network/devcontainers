FROM base-system:latest

USER root
RUN npm install -g mocha chai @types/mocha @types/chai
USER project

LABEL description="mocha intermediate layer"
