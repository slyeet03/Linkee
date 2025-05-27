use serde::Deserialize;
use crate::enums::KeyType;

#[derive(Debug, Deserialize)]
pub struct MouseMovePayload {
    pub x: i32,
    pub y: i32,
}

#[derive(Debug, Deserialize)]
pub struct MouseClickPayload {
    pub button: String,
}

#[derive(Debug, Deserialize)]
pub struct TypeTextPayload {
    pub text: String,
}

#[derive(Debug, Deserialize)]
pub struct PressKeyPayload {
    pub key: KeyType,
}

#[derive(Debug, Deserialize)]
pub struct ModifierPayload {
    pub modifier: String,
    pub action: String, // "hold" or "release"
}

#[derive(Debug, Deserialize)]
pub struct KeyComboPayload {
    pub modifiers: Vec<String>,
    pub key: String,
}

#[derive(Debug, Deserialize)]
pub struct MediaPayload {
    pub action: String,
}

#[derive(Debug, Deserialize)]
pub struct VolumePayload {
    pub action: String,
}