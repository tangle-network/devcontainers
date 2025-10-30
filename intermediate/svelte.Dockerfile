FROM base-system:latest

USER root
RUN npm install -g svelte @sveltejs/kit @sveltejs/adapter-auto
USER project

LABEL description="svelte intermediate layer"
