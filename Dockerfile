FROM rust:1.86-alpine AS planner 
RUN apk add --no-cache musl-dev

WORKDIR /app
RUN cargo install cargo-chef --locked

COPY .cargo/config.toml /usr/local/cargo/config.toml

COPY connect/Cargo.toml connect/Cargo.toml
COPY common/Cargo.toml  common/Cargo.toml

WORKDIR /app/connect
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo chef prepare \
      --recipe-path ../recipe.json \
      --bin connect

FROM planner AS builder
WORKDIR /app
COPY --from=planner /app/recipe.json ./
    
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo chef cook \
      --recipe-path recipe.json \
      --manifest-path connect/Cargo.toml \
      --profile build-speed \
      --bin connect \
      --locked \
      --offline \
      --no-build

COPY common/ common/
COPY connect/ connect/

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build \
      --manifest-path connect/Cargo.toml \
      --profile build-speed \
      --bin connect \
      --offline
      
FROM scratch AS runtime
COPY --from=builder /app/connect/target/build-speed/connect /usr/local/bin/connect
ENTRYPOINT ["/usr/local/bin/connect"]