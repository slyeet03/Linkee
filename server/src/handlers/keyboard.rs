use axum::{Json, response::IntoResponse, http::StatusCode};
use enigo::{Enigo, Key, Settings, Direction::{Click, Press, Release}, Keyboard};
use crate::models::{TypeTextPayload, PressKeyPayload, ModifierPayload, KeyComboPayload};
use crate::enums::KeyType;
use tracing::info;
use std::collections::HashMap;
use tokio::sync::Mutex;
use std::sync::Arc;
use once_cell::sync::Lazy;
use axum::debug_handler;

static HELD_MODIFIERS: Lazy<Arc<Mutex<HashMap<String, bool>>>> = Lazy::new(|| {
    Arc::new(Mutex::new(HashMap::new()))
});

pub async fn type_text(Json(payload): Json<TypeTextPayload>) -> impl IntoResponse {
    info!("Typing text: {}", payload.text);

    let mut enigo = match Enigo::new(&Settings::default()) {
        Ok(e) => e,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)),
    };

    match enigo.text(&payload.text) {
        Ok(_) => (StatusCode::OK, "Text typed".to_string()),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, format!("Text typing failed: {}", e)),
    }
}

pub async fn press_key(Json(payload): Json<PressKeyPayload>) -> impl IntoResponse {
    info!("Pressing key: {:?}", payload.key);

    let mut enigo = match Enigo::new(&Settings::default()) {
        Ok(e) => e,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)),
    };

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
        KeyType::Cmd => Key::Meta,
    };

    match enigo.key(key, Click) {
        Ok(_) => (StatusCode::OK, "Key pressed".to_string()),
        Err(e) => (StatusCode::INTERNAL_SERVER_ERROR, format!("Key press failed: {}", e)),
    }
}

pub async fn handle_modifier(
    Json(payload): Json<ModifierPayload>
) -> Result<(StatusCode, String), (StatusCode, String)> {
    info!("Modifier action: {} {}", payload.modifier, payload.action);

    let key = match payload.modifier.as_str() {
        "Alt" => Key::Alt,
        "Control" => Key::Control,
        "Shift" => Key::Shift,
        "Cmd" => Key::Meta,
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid modifier key".to_string())),
    };

    let mut modifiers = HELD_MODIFIERS.lock().await;
    
    let result = match payload.action.as_str() {
        "hold" => {
            let mut enigo = Enigo::new(&Settings::default()).map_err(|e| {
                (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e))
            })?;
            
            enigo.key(key, Press).map_err(|e| {
                (StatusCode::INTERNAL_SERVER_ERROR, format!("Modifier press failed: {}", e))
            })?;
            
            modifiers.insert(payload.modifier.clone(), true);
            Ok((StatusCode::OK, "Modifier held".to_string()))
        },
        "release" => {
            let mut enigo = Enigo::new(&Settings::default()).map_err(|e| {
                (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e))
            })?;
            
            enigo.key(key, Release).map_err(|e| {
                (StatusCode::INTERNAL_SERVER_ERROR, format!("Modifier release failed: {}", e))
            })?;
            
            modifiers.remove(&payload.modifier);
            Ok((StatusCode::OK, "Modifier released".to_string()))
        },
        _ => Err((StatusCode::BAD_REQUEST, "Invalid modifier action".to_string())),
    };

    result
}
pub async fn press_key_combo(Json(payload): Json<KeyComboPayload>) -> impl IntoResponse {
    info!("Key combo: {:?} + {}", payload.modifiers, payload.key);

    let mut enigo = match Enigo::new(&Settings::default()) {
        Ok(e) => e,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e)),
    };

    let key = match string_to_key(&payload.key) {
        Some(k) => k,
        None => return (StatusCode::BAD_REQUEST, format!("Invalid key: {}", payload.key)),
    };

    let mut modifier_keys = Vec::new();
    for modifier_str in &payload.modifiers {
        let modifier_key = match modifier_str.as_str() {
            "Alt" => Key::Alt,
            "Control" => Key::Control,
            "Shift" => Key::Shift,
            "Cmd" => Key::Meta,
            _ => continue,
        };
        if let Err(e) = enigo.key(modifier_key, Press) {
            return (StatusCode::INTERNAL_SERVER_ERROR, format!("Modifier press failed: {}", e));
        }
        modifier_keys.push(modifier_key);
    }

    if let Err(e) = enigo.key(key, Click) {
        return (StatusCode::INTERNAL_SERVER_ERROR, format!("Key press failed: {}", e));
    }

    for modifier_key in modifier_keys.iter().rev() {
        if let Err(e) = enigo.key(*modifier_key, Release) {
            return (StatusCode::INTERNAL_SERVER_ERROR, format!("Modifier release failed: {}", e));
        }
    }

    (StatusCode::OK, "Key combo executed".to_string())
}
#[debug_handler]
pub async fn clear_all_modifiers() -> Result<(StatusCode, String), (StatusCode, String)> {
    info!("Clearing all modifiers");

    let modifiers_to_clear: Vec<String> = {
        let modifiers = HELD_MODIFIERS.lock().await;
        modifiers.keys().cloned().collect()
    };

    for modifier_name in modifiers_to_clear {
        let key = match modifier_name.as_str() {
            "Alt" => Key::Alt,
            "Control" => Key::Control,
            "Shift" => Key::Shift,
            "Cmd" => Key::Meta,
            _ => continue,
        };
        
        let mut enigo = Enigo::new(&Settings::default()).map_err(|e| {
            (StatusCode::INTERNAL_SERVER_ERROR, format!("Enigo init failed: {}", e))
        })?;
        
        enigo.key(key, Release).map_err(|e| {
            (StatusCode::INTERNAL_SERVER_ERROR, format!("Modifier release failed: {}", e))
        })?;
    }

    HELD_MODIFIERS.lock().await.clear();

    Ok((StatusCode::OK, "All modifiers cleared".to_string()))
}
fn string_to_key(key_str: &str) -> Option<Key> {
    match key_str {
        "Alt" => Some(Key::Alt),
        "Backspace" => Some(Key::Backspace),
        "CapsLock" => Some(Key::CapsLock),
        "Control" => Some(Key::Control),
        "Delete" => Some(Key::Delete),
        "Down" => Some(Key::DownArrow),
        "Escape" => Some(Key::Escape),
        "Left" => Some(Key::LeftArrow),
        "Right" => Some(Key::RightArrow),
        "Shift" => Some(Key::Shift),
        "Space" => Some(Key::Space),
        "Tab" => Some(Key::Tab),
        "Up" => Some(Key::UpArrow),
        "Enter" => Some(Key::Return),
        "Cmd" => Some(Key::Meta),
        _ => {
            if key_str.len() == 1 {
                let ch = key_str.chars().next().unwrap();
                Some(Key::Unicode(ch))
            } else {
                None
            }
        }
    }
}