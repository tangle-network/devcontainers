FROM nodejs:latest

RUN npm install -g convex

LABEL description="convex infrastructure layer"
