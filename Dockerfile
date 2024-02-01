FROM rust:alpine AS builder

WORKDIR /netto

# Dependencies
RUN rustup component add rustfmt
RUN apk add --no-cache musl-dev elfutils-dev clang16
RUN cargo install wasm-pack

# Build
COPY . .
RUN apk add --no-cache make linux-headers zstd-dev zlib-static
RUN cargo build -p netto --release
# curl https://github.com/rustwasm/wasm-pack/releases/download/v0.12.1/wasm-pack-v0.12.1-aarch64-unknown-linux-musl.tar.gz
RUN wasm-pack build --no-typescript --target web --out-dir ../www/pkg web-frontend

FROM ubuntu:22.04

WORKDIR /netto
COPY --from=builder /netto/target/release/netto .
COPY --from=builder /netto/www www/
RUN apt update && apt install -y libelf1 && rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGINT
ENTRYPOINT ["/netto/netto"]
