FROM nodejs:latest

RUN npm install -g convex pg @types/pg

LABEL description="Combined: convex, postgresql"
