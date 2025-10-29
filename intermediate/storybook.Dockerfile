FROM base-system:latest

USER root
RUN npm install -g storybook @storybook/react @storybook/addon-essentials
USER project

LABEL description="storybook intermediate layer"
