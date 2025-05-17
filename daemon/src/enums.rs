use clap::{Parser, Subcommand, Args, ValueEnum};

#[derive(Parser)]
pub struct Cli {
    #[command(subcommand)]
    pub category: Command,
}

#[derive(Subcommand)]
pub enum Command {
    Mouse(MouseCommands),
    Keyboard(KeyboardCommands),
    Media(MediaCommands),
    Volume(VolumeCommands),
}

#[derive(Args)]
pub struct MouseCommands {
    #[command(subcommand)]
    pub command: MouseSubcommand,
}

#[derive(Args)]
pub struct KeyboardCommands {
    #[command(subcommand)]
    pub command: KeyboardSubcommand,
}

#[derive(Args)]
pub struct MediaCommands {
    #[command(subcommand)]
    pub command: MediaSubcommand,
}

#[derive(Args)]
pub struct VolumeCommands {
    #[command(subcommand)]
    pub command: VolumeSubcommand,
}

#[derive(Subcommand)]
pub enum MouseSubcommand {
    Move { x: i32, y: i32 },
    LeftClick,
    RightClick,
    MiddleClick,
    ScrollUp,
    ScrollDown,
}

#[derive(Subcommand)]
pub enum KeyboardSubcommand {
    Type { text: String },
    Press { key: KeyType },
}

#[derive(Clone, ValueEnum)]
pub enum KeyType {
    Alt,
    Backspace,
    CapsLock,
    Control,
    Delete,
    Down,
    Escape,
    Left,
    Right,
    Shift,
    Space,
    Tab,
    Up,
}

#[derive(Subcommand)]
pub enum MediaSubcommand {
    Next,
    PlayPause,
    Prev,
    Stop,
}

#[derive(Subcommand)]
pub enum VolumeSubcommand {
    Up,
    Down,
    Mute,
}