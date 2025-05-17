use clap::Parser;
use enigo::{Axis, Button, Coordinate, Direction::Click, Enigo, Key, Settings, Keyboard, Mouse};
use enums::{Cli, Command, KeyboardSubcommand, KeyType, MouseSubcommand, MediaSubcommand, VolumeSubcommand};
use std::process::Command as OtherCommand;

mod enums;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();
    let mut enigo = Enigo::new(&Settings::default())?;

    match cli.category {
        Command::Mouse(cmd) => match cmd.command {
            MouseSubcommand::Move { x, y } => {
                enigo.move_mouse(x, y, Coordinate::Abs)?;
            }
            MouseSubcommand::LeftClick => {
                enigo.button(Button::Left, Click)?;
            }
            MouseSubcommand::RightClick => {
                enigo.button(Button::Right, Click)?;
            }
            MouseSubcommand::MiddleClick => {
                enigo.button(Button::Middle, Click)?;
            }
            MouseSubcommand::ScrollUp => {
                enigo.scroll(1, Axis::Vertical)?;
            }
            MouseSubcommand::ScrollDown => {
                enigo.scroll(-1, Axis::Vertical)?;
            }
        },
        Command::Keyboard(cmd) => match cmd.command {
            KeyboardSubcommand::Type { text } => {
                enigo.text(&text)?;
            }
            KeyboardSubcommand::Press { key } => match key {
                KeyType::Alt => enigo.key(Key::Alt, Click)?,
                KeyType::Backspace => enigo.key(Key::Backspace, Click)?,
                KeyType::CapsLock => enigo.key(Key::CapsLock, Click)?,
                KeyType::Control => enigo.key(Key::Control, Click)?,
                KeyType::Delete => enigo.key(Key::Delete, Click)?,
                KeyType::Down => enigo.key(Key::DownArrow, Click)?,
                KeyType::Escape => enigo.key(Key::Escape, Click)?,
                KeyType::Left => enigo.key(Key::LeftArrow, Click)?,
                KeyType::Right => enigo.key(Key::RightArrow, Click)?,
                KeyType::Shift => enigo.key(Key::Shift, Click)?,
                KeyType::Space => enigo.key(Key::Space, Click)?,
                KeyType::Tab => enigo.key(Key::Tab, Click)?,
                KeyType::Up => enigo.key(Key::UpArrow, Click)?,
            },
        },
        Command::Media(cmd) => match cmd.command {
            MediaSubcommand::Next => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("tell application \"System Events\" to key code 124")
                    .status()?;
            }
            MediaSubcommand::PlayPause => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("tell application \"System Events\" to key code 179")
                    .status()?;
            }
            MediaSubcommand::Prev => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("tell application \"System Events\" to key code 123")
                    .status()?;
            }
            MediaSubcommand::Stop => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("tell application \"System Events\" to key code 182")
                    .status()?;
            }
        },
        Command::Volume(cmd) => match cmd.command {
            VolumeSubcommand::Up => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("set volume output volume (output volume of (get volume settings) + 5)")
                    .status()?;
            }
            VolumeSubcommand::Down => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("set volume output volume (output volume of (get volume settings) - 5)")
                    .status()?;
            }
            VolumeSubcommand::Mute => {
                OtherCommand::new("osascript")
                    .arg("-e")
                    .arg("set volume output muted not (output muted of (get volume settings))")
                    .status()?;
            }
        },
    }

    Ok(())
}