FROM rust:1.86-slim AS planner   

RUN cargo install cargo-chef --locked

WORKDIR /app

