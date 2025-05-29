use axum::{
    routing::{get, post},
    Router,
};
use std::net::SocketAddr;
use axum::serve;
use tokio::net::TcpListener;
use socket2::{Domain, Socket, Type};
use tracing_subscriber;
use tower_http::trace::TraceLayer;
use std::time::Duration;

mod handlers;
mod models;
mod enums;

#[tokio::main]
async fn main() {
    // Initialize tracing subscriber (logger)
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    // Set up address to bind to all interfaces
    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));

    // Create a socket and configure it
    let socket = Socket::new(Domain::IPV4, Type::STREAM, None).unwrap();
    socket.set_reuse_address(true).unwrap();
    socket.set_reuse_port(true).unwrap();
    socket.bind(&addr.into()).unwrap();
    socket.listen(1024).unwrap();

    // Convert socket into a Tokio TcpListener
    let listener = TcpListener::from_std(socket.into()).unwrap();

    println!("Current working dir: {:?}", std::env::current_dir().unwrap());

    // Log host info
    let hostname = hostname::get().unwrap_or_default();
    tracing::info!("Starting server on hostname: {:?}", hostname);
    tracing::info!("Listening on: http://{}", addr);

    // Define routes with logging middleware
    let app = Router::new()
        .route("/", get(|| async { "Server is running!" }))
        .route("/status", get(|| async { "OK" }))
        .route("/ping", get(|| async { "pong" }))
        .route("/mouse/move", post(handlers::mouse::move_mouse))
        .route("/mouse/click", post(handlers::mouse::click_mouse))
        .route("/keyboard/type", post(handlers::keyboard::type_text))
        .route("/keyboard/press", post(handlers::keyboard::press_key))
        .route("/keyboard/modifier", post(handlers::keyboard::handle_modifier))
        .route("/keyboard/combo", post(handlers::keyboard::press_key_combo))
        .route("/keyboard/clear-modifiers", post(handlers::keyboard::clear_all_modifiers))
        .route("/media/control", post(handlers::media::handle_media))
        .route("/volume/control", post(handlers::media::handle_volume))
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(|request: &axum::http::Request<_>| {
                    tracing::info_span!(
                        "request",
                        method = ?request.method(),
                        uri = %request.uri(),
                        headers = ?request.headers()
                    )
                })
                .on_response(
                    |response: &axum::http::Response<_>, latency: Duration, _span: &tracing::Span| {
                        tracing::info!(
                            "response => status: {}, latency: {:.2?}",
                            response.status(),
                            latency
                        );
                    },
                ),
        );

    // Start serving
    if let Err(e) = serve(listener, app).await {
        tracing::error!("Server failed: {}", e);
    }
}
