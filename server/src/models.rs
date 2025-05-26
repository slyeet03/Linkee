use crate::enums::KeyType;
use serde::{Serialize, Deserialize};


#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MouseMovePayload {
    pub x: i32,
    pub y: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MouseClickPayload {
    pub button: String, // "left", "right", "middle"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TypeTextPayload {
    pub text: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PressKeyPayload {
    pub key: KeyType,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MediaPayload {
    pub action: String, // "playpause", "next", "prev", "stop"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VolumePayload {
    pub action: String, // "up", "down", "mute"
}
