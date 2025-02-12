FROM alpine AS builder

RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
  unzip curl lscpu

WORKDIR /app

RUN if [ $(lscpu | grep -c aarch64) -gt 0 ]; then ARCH=arm64; else ARCH=amd64; fi; curl -s https://api.github.com/repos/anacrolix/cove/releases/latest | grep browser_download_url | grep $ARCH | cut -d '"' -f 4 | xargs curl -L -o cove.zip

RUN unzip cove.zip

FROM gcr.io/distroless/cc

WORKDIR /data

COPY --from=builder /app/cove /app/cove
COPY --from=builder /app/dht-indexer-rust.so /app/dht-indexer-rust.so

CMD ["/app/cove"]
