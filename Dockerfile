FROM alpine AS builder

RUN apk update \
  && apk upgrade \
  && apk add --no-cache \
  unzip curl lscpu

WORKDIR /app

RUN if [ $(lscpu | grep -c aarch64) -gt 0 ]; then ARCH=arm64; else ARCH=amd64; fi; curl -s https://api.github.com/repos/anacrolix/cove/releases/latest | grep browser_download_url | grep $ARCH | cut -d '"' -f 4 | xargs curl -L -o cove.zip

RUN if [ $(lscpu | grep -c aarch64) -gt 0 ]; then ARCH=arm64; else ARCH=amd64; fi; curl -L https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-$ARCH-static.tar.xz -o ffmpeg.tar.xz

RUN unzip cove.zip

RUN mkdir ffmpeg

RUN tar xvaf ffmpeg.tar.xz -C ffmpeg --strip-components=1

FROM gcr.io/distroless/cc

WORKDIR /data

COPY --from=builder /app/cove /app/cove
COPY --from=builder /app/dht-indexer-rust.so /app/dht-indexer-rust.so

COPY --from=builder /app/ffmpeg/ffprobe /bin/ffprobe

CMD ["/app/cove"]
