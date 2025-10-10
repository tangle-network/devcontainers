FROM nodejs:latest

RUN npm install -g mongodb

LABEL description="mongodb infrastructure layer"
