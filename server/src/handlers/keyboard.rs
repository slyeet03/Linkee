use axum::{Json, response::IntoResponse, http::StatusCode};
use enigo::{Enigo, Key, Settings, Direction::Click, Keyboard};
use crate::models::{TypeTextPayload, PressKeyPayload};
use crate::enums::KeyType;
use tracing::info;

pub async fn type_text(Json(payload): Json<TypeTextPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Typing text: {}", payload.text);

    let mut enigo = Enigo::new(&Settings::default())
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)))?;

    enigo.text(&payload.text)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Text typing failed: {}", e)))?;

    Ok("Text typed")
}

pub async fn press_key(Json(payload): Json<PressKeyPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Pressing key: {:?}", payload.key);

    let mut enigo = Enigo::new(&Settings::default())
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)))?;

    let key = match payload.key {
        KeyType::Alt => Key::Alt,
        KeyType::Backspace => Key::Backspace,
        KeyType::CapsLock => Key::CapsLock,
        KeyType::Control => Key::Control,
        KeyType::Delete => Key::Delete,
        KeyType::Down => Key::DownArrow,
        KeyType::Escape => Key::Escape,
        KeyType::Left => Key::LeftArrow,
        KeyType::Right => Key::RightArrow,
        KeyType::Shift => Key::Shift,
        KeyType::Space => Key::Space,
        KeyType::Tab => Key::Tab,
        KeyType::Up => Key::UpArrow,
        KeyType::Enter => Key::Return,
    };

    enigo.key(key, Click)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Key press failed: {}", e)))?;

    Ok("Key pressed")
}
