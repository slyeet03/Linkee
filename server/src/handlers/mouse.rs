use axum::{Json, response::IntoResponse, http::StatusCode};
use enigo::{Coordinate, Direction::Click, Enigo, Settings, Button, Mouse};
use crate::models::{MouseMovePayload, MouseClickPayload};
use tracing::info;

pub async fn move_mouse(Json(payload): Json<MouseMovePayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Moving mouse to x: {}, y: {}", payload.x, payload.y);

    let mut enigo = Enigo::new(&Settings::default())
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)))?;
    
    enigo.move_mouse(payload.x, payload.y, Coordinate::Abs)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Move failed: {}", e)))?;

    Ok("Mouse moved")
}

pub async fn click_mouse(Json(payload): Json<MouseClickPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Clicking mouse: {:?}", payload.button);

    let mut enigo = Enigo::new(&Settings::default())
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)))?;

    let button = match payload.button.as_str() {
        "left" => Button::Left,
        "right" => Button::Right,
        "middle" => Button::Middle,
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid mouse button".into())),
    };

    enigo.button(button, Click)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Click failed: {}", e)))?;

    Ok("Mouse clicked")
}
