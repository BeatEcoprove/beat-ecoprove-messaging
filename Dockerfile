FROM elixir:otp-28-alpine AS builder

RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm \
    cmake \
    openssl-dev

ENV MIX_ENV=prod

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

COPY config config
COPY priv priv
COPY lib lib

RUN mix phx.swagger.generate

RUN mix phx.digest 2>/dev/null || true

RUN mix compile

RUN MIX_ENV=prod mix release --overwrite

FROM elixir:otp-28-alpine

RUN apk add --no-cache \
    openssl \
    ncurses-libs \
    libstdc++ \
    libgcc

ENV MIX_ENV=prod \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN addgroup -g 1000 messaging && \
    adduser -D -u 1000 -G messaging messaging

WORKDIR /app

COPY --from=builder --chown=messaging:messaging /app/_build/prod/rel/messaging ./

USER messaging

EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD ["bin/messaging", "rpc", "1 + 1"]

CMD ["sh", "-c", "bin/messaging eval 'Messaging.Release.migrate()' && bin/messaging start"]
