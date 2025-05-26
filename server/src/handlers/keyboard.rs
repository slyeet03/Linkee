use axum::{Json, response::IntoResponse};
use enigo::{Enigo, Key, Settings, Direction::Click, Keyboard};
use crate::models::{TypeTextPayload, PressKeyPayload};
use crate::enums::KeyType;

#[axum::debug_handler]
pub async fn type_text(Json(payload): Json<TypeTextPayload>) -> impl IntoResponse {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();
    enigo.text(&payload.text).unwrap();
    "Typed Text".into_response()
}

#[axum::debug_handler]
pub async fn press_key(Json(payload): Json<PressKeyPayload>) -> impl IntoResponse {
    let mut enigo = Enigo::new(&Settings::default()).unwrap();
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
    };
    enigo.key(key, Click).unwrap();
    "Pressed Key".into_response()
}
