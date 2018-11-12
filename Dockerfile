FROM ruby:2.5.3-alpine3.8
ENV RAILS_ENV=development

RUN apk add --update --no-cache \
    build-base \
    tzdata \
    git

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir /usr/app
WORKDIR /usr/app

COPY . /usr/app/
# COPY Gemfile.lock /usr/app/
RUN bundle install

RUN cat Gemfile.lock

ADD . /usr/app
CMD ["./startup.dev.sh"]
