FROM golang:1.20.3-alpine AS builder

RUN apk add --no-cache git build-base gcc musl-dev
WORKDIR /app
COPY . /app
RUN go mod download
RUN go build

RUN apk --no-cache --virtual .build-deps add git build-base \
   && git clone --depth=1 https://github.com/blechschmidt/massdns.git \
   && cd massdns && make && apk del .build-deps && cp ./bin/massdns /usr/local/bin


FROM alpine:3.17.3
RUN apk -U upgrade --no-cache \
    && apk add --no-cache bind-tools ca-certificates chromium
COPY --from=builder /usr/local/bin/massdns /usr/local/bin/
COPY --from=builder /app/puredns /usr/local/bin/

ENTRYPOINT ["puredns"]
