FROM elixir:alpine

RUN apk add --update postgresql-client
RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

RUN mix deps.get
RUN mix do compile
RUN mix phx.digest


CMD ["/app/start.sh"]
