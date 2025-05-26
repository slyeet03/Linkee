use axum::{Json, response::IntoResponse};
use std::process::Command;
use crate::models::{MediaPayload, VolumePayload};

#[axum::debug_handler]
pub async fn handle_media(Json(payload): Json<MediaPayload>) -> impl IntoResponse {
    let script = match payload.action.as_str() {
        "playpause" => "pause",
        "next" => "next track",
        "prev" => "previous track",
        "stop" => "key code 182",
        _ => return "Invalid media command".into_response(),
    };
    Command::new("osascript").arg("-e").arg(format!("tell application \"System Events\" to {}", script)).status().unwrap();
    "Media Control Executed".into_response()
}

#[axum::debug_handler]
pub async fn handle_volume(Json(payload): Json<VolumePayload>) -> impl IntoResponse {
    let script = match payload.action.as_str() {
        "up" => "set volume output volume (output volume of (get volume settings) + 5)",
        "down" => "set volume output volume (output volume of (get volume settings) - 5)",
        "mute" => "set volume output muted not (output muted of (get volume settings))",
        _ => return "Invalid volume command".into_response(),
    };
    Command::new("osascript").arg("-e").arg(script).status().unwrap();
    "Volume Control Executed".into_response()
}
