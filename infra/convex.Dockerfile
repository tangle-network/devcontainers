FROM base-system:latest

USER root
RUN npm install -g convex convex-dev

# Pre-warm npm cache with project-specific packages (non-fatal if packages unavailable, run as root)
RUN npm cache add convex@latest convex-helpers@latest @convex-dev/auth@latest || true

USER agent

LABEL description="convex infrastructure layer"
