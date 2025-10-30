FROM php:latest

USER root
RUN curl -sS https://get.symfony.com/cli/installer | bash && \
    mv /root/.symfony5/bin/symfony /usr/local/bin/symfony

USER project

LABEL description="symfony intermediate layer"
