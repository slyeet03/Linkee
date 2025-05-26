use axum::{routing::{get, post}, Router};
use std::net::SocketAddr;
use axum::serve;
use tokio::net::TcpListener;
use socket2::{Socket, Domain, Type};

mod handlers;
mod models;
mod enums;

#[tokio::main]
async fn main() {
    // Set up address
    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));

    // Create socket with reuseaddr and reuseport option
    let socket = Socket::new(Domain::IPV4, Type::STREAM, None).unwrap();

    socket.set_reuse_address(true).unwrap();
    socket.set_reuse_port(true).unwrap();  // <-- important!

    socket.bind(&addr.into()).unwrap();
    socket.listen(1024).unwrap();

    // Convert to Tokio listener
    let listener = TcpListener::from_std(socket.into()).unwrap();

    let app = Router::new()
        .route("/", get(|| async { "Server is running!" }))
        .route("/ping", get(|| async { "pong" }))
        .route("/mouse/move", post(handlers::mouse::move_mouse))
        .route("/mouse/click", post(handlers::mouse::click_mouse))
        .route("/keyboard/type", post(handlers::keyboard::type_text))
        .route("/keyboard/press", post(handlers::keyboard::press_key))
        .route("/media/control", post(handlers::media::handle_media))
        .route("/volume/control", post(handlers::media::handle_volume));

    println!("Server listening on http://{}", addr);

    serve(listener, app).await.unwrap();
}
