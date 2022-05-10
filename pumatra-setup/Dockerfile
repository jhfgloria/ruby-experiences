# Dockerfile

FROM ruby:3.0.3

WORKDIR /app
COPY . /app
RUN bundle install

EXPOSE 8000

CMD ["bundle", "exec", "foreman", "start", "web=1", "-f", "Procfile"]
