FROM elixir:alpine AS builder

ENV MIX_ENV=prod \
    APP_NAME=server \
    ROOT_PATH="/assets/images" \
    DATABASE_URL="ecto://postgres:postgres@db/fileserver_prod"

WORKDIR /opt/app

# COPY shell.nix default.nix ./
# COPY nix ./

# RUN nix-shell --command "echo loaded deps"

COPY mix.exs mix.lock ./

RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get && mix deps.compile

COPY . .

RUN mix compile && mix release

RUN \
  mkdir -p /opt/built && \
  cp -rf _build/${MIX_ENV}/rel/${APP_NAME} /opt/built

FROM elixir:alpine
RUN apk add --update postgresql-client bash openssl-dev

ENV APP_NAME=server

WORKDIR /opt/app

COPY start.sh .
COPY --from=builder /opt/built .

CMD ["/bin/bash", "/opt/app/start.sh"]
