use axum::{Json, response::IntoResponse, http::StatusCode};
use std::process::Command;
use crate::models::{MediaPayload, VolumePayload};
use tracing::info;

pub async fn handle_media(Json(payload): Json<MediaPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    let script = match payload.action.as_str() {
        "playpause" => "key code 144",
        "next" => "next track",
        "prev" => "previous track",
        "stop" => "key code 182",
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid media command".into())),
    };

    info!("Executing media control: {}", payload.action);

    let status = Command::new("osascript")
        .arg("-e")
        .arg(format!("tell application \"System Events\" to {}", script))
        .status()
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Failed to run osascript: {}", e)))?;

    if status.success() {
        Ok("Media control executed")
    } else {
        Err((StatusCode::INTERNAL_SERVER_ERROR, "Media command failed".into()))
    }
}

pub async fn handle_volume(Json(payload): Json<VolumePayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    let script = match payload.action.as_str() {
        "up" => "set volume output volume (output volume of (get volume settings) + 5)",
        "down" => "set volume output volume (output volume of (get volume settings) - 5)",
        "mute" => "set volume output muted not (output muted of (get volume settings))",
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid volume command".into())),
    };

    info!("Executing volume control: {}", payload.action);

    let status = Command::new("osascript")
        .arg("-e")
        .arg(script)
        .status()
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, format!("Failed to run osascript: {}", e)))?;

    if status.success() {
        Ok("Volume control executed")
    } else {
        Err((StatusCode::INTERNAL_SERVER_ERROR, "Volume command failed".into()))
    }
}
