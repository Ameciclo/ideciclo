FROM elixir:1.9.0-alpine AS build
RUN apk add --no-cache build-base git python
WORKDIR /ideciclo
RUN mix local.hex --force && \
  mix local.rebar --force
ENV DATABASE_URL=${DATABASE_URL} \
  SECRET_KEY_BASE=${SECRET_KEY_BASE} \
  MIX_ENV=prod
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile
COPY priv priv
RUN mix phx.digest
COPY lib lib
RUN mix do compile, release

FROM alpine:3.11.12 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /ideciclo

RUN chown nobody:nobody /ideciclo

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /ideciclo/_build/prod/rel/ideciclo ./

ENV HOME=/ideciclo

CMD ["bin/ideciclo", "start"]