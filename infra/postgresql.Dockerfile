FROM nodejs:latest

RUN npm install -g pg @types/pg

LABEL description="postgresql infrastructure layer"
