FROM bitwalker/alpine-elixir:1.8.1 as builder

ENV MIX_ENV test
RUN apk update && \
    apk --no-cache --update upgrade alpine-sdk && \
    apk --no-cache add alpine-sdk && \
    rm -rf /var/cache/**/*
COPY . /app
WORKDIR /app
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix format --check-formatted && \
    mix test
RUN MIX_ENV=prod mix release

FROM alpine:3.9
RUN apk update && \
    apk add --no-cache bash openssl && \
    rm -rf /var/cache/**/*
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/data_generator/ .
ENV PORT 80
EXPOSE 80
CMD ["bin/data_generator", "foreground"]
