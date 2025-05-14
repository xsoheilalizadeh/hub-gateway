FROM rust:1.86-alpine AS planner 
RUN apk add --no-cache musl-dev

WORKDIR /app

COPY .cargo/config.toml /usr/local/cargo/config.toml

RUN cargo install cargo-chef --locked
COPY . .
RUN cargo chef prepare --recipe-path recipe.json


FROM planner AS builder  
COPY --from=planner /app/recipe.json recipe.json

WORKDIR /app

# Cache your registry & git index between builds (BuildKit mount)
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo chef cook --profile build-speed --recipe-path recipe.json

COPY . .

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --profile build-speed

FROM scratch AS runtime
COPY --from=builder /app/target/build-speed/connect /usr/local/bin/
ENTRYPOINT ["connect"]    