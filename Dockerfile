FROM ruby:2.4.1
MAINTAINER Angel M Miguel <angel@laux.es>

# Ruby base template
COPY Gemfile* /app/
WORKDIR /app

RUN gem install bundler && bundle install

CMD ["irb"]
