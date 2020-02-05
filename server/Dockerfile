FROM elixir:alpine

RUN apk add --update postgresql-client
RUN mix local.hex --force && mix local.rebar --force
RUN mkdir /app
WORKDIR /app
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY mix.exs .
COPY mix.lock .
COPY start.sh .

RUN mix deps.get
RUN mix do compile
RUN mix phx.digest

CMD ["/app/start.sh"]
