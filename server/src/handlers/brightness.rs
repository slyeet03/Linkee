use axum::{Json, response::IntoResponse, http::StatusCode};
use std::process::Command;
use crate::models::{BrightnessPayload};
use tracing::info;

pub async fn handle_brightness(Json(payload): Json<BrightnessPayload>) -> Result<impl IntoResponse, (StatusCode, String)> {
    info!("Executing brightness control: {}", payload.action);
    
    let result = match payload.action.as_str() {
        "up" => {
            Command::new("sh")
                .arg("-c")
                .arg("osascript -e 'tell application \"System Events\"' -e 'key code 144' -e ' end tell'")
                .status()
        },
        "down" => {
            Command::new("sh")
                .arg("-c") 
                .arg("osascript -e 'tell application \"System Events\"' -e 'key code 145' -e ' end tell'")
                .status()
        },
        _ => return Err((StatusCode::BAD_REQUEST, "Invalid brightness command".into())),
    };
    
    match result {
        Ok(status) if status.success() => Ok("Brightness control executed"),
        Ok(_) => Err((StatusCode::INTERNAL_SERVER_ERROR, "Brightness command failed".into())),
        Err(e) => Err((StatusCode::INTERNAL_SERVER_ERROR, format!("Failed to execute command: {}", e))),
    }
}