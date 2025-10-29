FROM ruby:latest

RUN gem install rails bundler

LABEL description="rails intermediate layer"
