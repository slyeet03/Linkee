use axum::{routing::post, Router};
use std::net::SocketAddr;
use axum::serve;
use tokio::net::TcpListener;

mod handlers;
mod models;
mod enums;

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/mouse/move", post(handlers::mouse::move_mouse))
        .route("/mouse/click", post(handlers::mouse::click_mouse))
        .route("/keyboard/type", post(handlers::keyboard::type_text))
        .route("/keyboard/press", post(handlers::keyboard::press_key))
        .route("/media/control", post(handlers::media::handle_media))
        .route("/volume/control", post(handlers::media::handle_volume));

    let addr = SocketAddr::from(([0, 0, 0, 0], 3000));
    let listener = TcpListener::bind(addr).await.unwrap();

    println!("Server listening on http://{}", addr);

    serve(listener, app).await.unwrap();
}
