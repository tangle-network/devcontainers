FROM php:latest

ENV     PATH=/root/.composer/vendor/bin:$PATH

USER root
RUN composer global require laravel/installer

USER project

LABEL description="laravel intermediate layer"
