use axum::{Json, response::IntoResponse};
use enigo::{Coordinate, Direction::Click, Enigo, Settings, Button, Mouse};
use crate::models::{MouseMovePayload, MouseClickPayload};

#[axum::debug_handler]
pub async fn move_mouse(Json(payload): Json<MouseMovePayload>) -> impl IntoResponse {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();
    enigo.move_mouse(payload.x, payload.y, Coordinate::Abs).unwrap();
    "Moved Mouse".into_response()
}

#[axum::debug_handler]
pub async fn click_mouse(Json(payload): Json<MouseClickPayload>) -> impl IntoResponse {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();
    let button = match payload.button.as_str() {
        "left" => Button::Left,
        "right" => Button::Right,
        "middle" => Button::Middle,
        _ => return "Invalid button".into_response(),
    };
    enigo.button(button, Click).unwrap();
    "Clicked Mouse".into_response()
}
