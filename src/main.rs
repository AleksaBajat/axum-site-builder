use axum::{http::StatusCode, routing::get, Router};

async fn fallback() -> (StatusCode, &'static str) {
    (StatusCode::NOT_FOUND, "Not found")
}

#[tokio::main]
async fn main() {
    let admin_routes = Router::new().route("/", get(|| async { "Admin" }));

    let router = Router::new()
        .nest("/admin", admin_routes)
        .route("/", get(|| async { "Hello, World" }))
        .route("/healthcheck", get(|| async { "200" }))
        .fallback(fallback);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, router).await.unwrap();
}
