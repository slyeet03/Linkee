# Linkee

A cross-platform remote control application that turns your mobile device into a wireless mouse, keyboard, and media controller for your computer.

## Overview

Linkee consists of two components:
- **Flutter Client**: A mobile app that provides touch-based controls
- **Rust Server**: A lightweight server that runs on your computer and executes the commands

## Features

### 🖱️ Mouse Control
- Touch trackpad with gesture-based mouse movement
- Left, right, and middle mouse button clicks
- Smooth cursor control with adjustable sensitivity

### ⌨️ Keyboard Input
- Full text typing capability
- Virtual keyboard with common keys (arrows, function keys, etc.)
- Modifier key support (Cmd, Alt, Ctrl, Shift) with visual feedback
- Key combinations and shortcuts

### 🎵 Media Controls
- Play/pause music and videos
- Skip to next/previous track
- Universal media key support

### 🔊 Volume Control
- Volume up/down controls
- Mute/unmute toggle
- System-level audio control

### 🔍 Auto-Discovery
- Automatic server detection on local network
- Manual IP configuration fallback
- Connection status monitoring

## Architecture

### Client (Flutter)
- **Screens**: Modular UI with bottom navigation between Mouse, Keyboard, Media, and Volume controls
- **Services**: Network communication and server discovery
- **State Management**: Real-time UI updates and connection handling

### Server (Rust)
- **HTTP API**: RESTful endpoints for all control functions
- **Cross-platform**: Uses `enigo` for system input simulation
- **Efficient**: Lightweight server with minimal resource usage

## API Endpoints

### Mouse
- `POST /mouse/move` - Move cursor to absolute coordinates
- `POST /mouse/click` - Perform mouse clicks

### Keyboard
- `POST /keyboard/type` - Type text strings
- `POST /keyboard/press` - Press individual keys
- `POST /keyboard/combo` - Execute key combinations
- `POST /keyboard/modifier` - Handle modifier key states

### Media
- `POST /media/control` - Control media playback (play/pause/next/prev)

### Volume
- `POST /volume/control` - Adjust system volume (up/down/mute)

### System
- `GET /status` - Health check endpoint
- `GET /ping` - Connection test

## Getting Started

### Prerequisites
- **Server**: Rust toolchain
- **Client**: Flutter SDK
- **Platform**: macOS, Windows, or Linux

### Installation

#### Server Setup
1. Clone the repository
2. Navigate to the server directory
3. Build and run:
   ```bash
   cargo run
   ```
4. Server will start on `http://0.0.0.0:8000`

#### Client Setup
1. Navigate to the client directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Usage
1. Start the server on your computer
2. Launch the mobile app
3. The app will automatically discover and connect to the server
4. If auto-discovery fails, manually enter your computer's IP address
5. Use the bottom navigation to switch between control modes

## Technical Details

### Dependencies

#### Server (Rust)
- `axum` - Web framework for HTTP API
- `enigo` - Cross-platform input simulation
- `tokio` - Async runtime
- `serde` - JSON serialization
- `tracing` - Logging framework

#### Client (Flutter)
- `http` - HTTP client for server communication
- `shared_preferences` - Local storage for settings

### Network Protocol
- Communication over HTTP REST API
- JSON payloads for all requests
- Default server port: 8000
- Local network discovery via IP scanning

### Platform Support
- **Server**: macOS, Windows, Linux
- **Client**: iOS, Android (Flutter cross-platform)

## Project Structure

```
linkee/
├── client/                 # Flutter mobile app
│   ├── lib/
│   │   ├── screens/       # UI screens
│   │   ├── services/      # Network services
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml
├── server/                # Rust server
│   ├── src/
│   │   ├── handlers/      # API handlers
│   │   ├── models.rs      # Data models
│   │   └── main.rs        # Server entry point
│   └── Cargo.toml
└── README.md
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on your target platforms
5. Submit a pull request

## License

This project is open source. Please check the license file for details.

## Troubleshooting

### Connection Issues
- Ensure both devices are on the same Wi-Fi network
- Check firewall settings on the computer
- Verify the server is running on port 8000
- Try manual IP configuration if auto-discovery fails

---

Transform your mobile device into the ultimate computer remote control with Linkee!