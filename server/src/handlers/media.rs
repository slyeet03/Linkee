use axum::{Json, response::IntoResponse, http::StatusCode};
use std::process::Command;
use crate::models::{MediaPayload, VolumePayload};
use tracing::info;

pub async fn handle_media(Json(payload): Json<MediaPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Executing media control: {}", payload.action);
    
    let result = match payload.action.as_str() {
        "playpause" => {
            Command::new("sh")
                .arg("-c")
                .arg("osascript -e 'tell application \"System Events\" to key code 49'")
                .status()
        },
        "next" => {
            Command::new("sh")
                .arg("-c") 
                .arg("osascript -e 'tell application \"System Events\" to key code 101'")
                .status()
        },
        "prev" => {
            Command::new("sh")
                .arg("-c")
                .arg("osascript -e 'tell application \"System Events\" to key code 18'")
                .status()
        },
        "stop" => {
            Command::new("osascript")
                .arg("-e")
                .arg("tell application \"Spotify\" to stop")
                .status()
        },
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid media command".into())),
    };
    
    match result {
        Ok(status) if status.success() => Ok("Media control executed"),
        Ok(_) => Err((StatusCode::INTERNAL_SERVER_ERROR, "Media command failed".into())),
        Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, format!("Failed to execute command: {}", e))),
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