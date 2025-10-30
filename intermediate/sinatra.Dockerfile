FROM ruby:latest

RUN gem install sinatra sinatra-contrib

LABEL description="sinatra intermediate layer"
