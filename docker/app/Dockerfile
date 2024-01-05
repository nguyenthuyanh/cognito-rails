FROM ruby:3.2.0

ENV TIMEZONE Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN mkdir /app/
WORKDIR  /app/

ENV APP_HOME /app/pognito
ENV RAILS_ENV development
ENV RACK_ENV development

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/

RUN bundle install --jobs 20 --retry 5

