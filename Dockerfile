FROM rust:1.80.0 AS base
WORKDIR /app
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo install cargo-chef --locked

FROM base AS chef
RUN cargo init
COPY Cargo.lock Cargo.toml /app/
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=chef /app/recipe.json recipe.json
RUN cargo chef cook --release --target x86_64-unknown-linux-musl --recipe-path recipe.json
COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM scratch AS empty
WORKDIR /app
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/site_builder  /app/
ENTRYPOINT [ "./site_builder" ]
EXPOSE 3000
