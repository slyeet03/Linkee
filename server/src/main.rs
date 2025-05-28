use axum::{routing::{get, post}, Router};
use std::net::SocketAddr;
use axum::serve;
use tokio::net::TcpListener;
use socket2::{Socket, Domain, Type};
use tracing_subscriber;

mod handlers;
mod models;
mod enums;

#[tokio::main]
async fn main() {
    // Initialize logger
    tracing_subscriber::fmt().init(); 

    // Set up address
    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));

    // Create socket with reuseaddr and reuseport option
    let socket = Socket::new(Domain::IPV4, Type::STREAM, None).unwrap();
    socket.set_reuse_address(true).unwrap();
    socket.set_reuse_port(true).unwrap();  
    socket.bind(&addr.into()).unwrap();
    socket.listen(1024).unwrap();

    // Convert to Tokio listener
    let listener = TcpListener::from_std(socket.into()).unwrap();

    // Define routes
    let app = Router::new()
        .route("/", get(|| async { "Server is running!" }))
        .route("/status", get(|| async { "OK" })) // Added missing status endpoint
        .route("/ping", get(|| async { "pong" }))
        .route("/mouse/move", post(handlers::mouse::move_mouse))
        .route("/mouse/click", post(handlers::mouse::click_mouse))
        .route("/keyboard/type", post(handlers::keyboard::type_text))
        .route("/keyboard/press", post(handlers::keyboard::press_key))
        .route("/keyboard/modifier", post(handlers::keyboard::handle_modifier))
        .route("/keyboard/combo", post(handlers::keyboard::press_key_combo))
        .route("/keyboard/clear-modifiers", post(handlers::keyboard::clear_all_modifiers))
        .route("/media/control", post(handlers::media::handle_media))
        .route("/volume/control", post(handlers::media::handle_volume));

    println!("Server listening on http://{}", addr);

    serve(listener, app).await.unwrap();
}
