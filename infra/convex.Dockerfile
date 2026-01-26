FROM base-system:latest

USER root
RUN npm install -g convex convex-dev
USER agent

# Pre-warm npm cache with project-specific packages
RUN npm cache add convex@latest convex-helpers@latest @convex-dev/auth@latest

LABEL description="convex infrastructure layer"
