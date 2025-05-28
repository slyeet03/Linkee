# 🖱Linkee

A Flutter mobile app to control your Mac (mouse, keyboard, media, and volume) over local Wi-Fi using a Rust-based server.

## Structure

- `server/` – Rust backend using Axum
- `client/` – Flutter frontend app

## How to Run

### 1. Start the Rust Server

```bash
cd server
cargo run
```

Make sure your Mac's IP is visible to your mobile device and they are on the same Wi-Fi network.

### 2. Run the Flutter Client

```bash
cd client
flutter run
```
## Dependencies

### Rust (Server)
- axum
- tokio
- enigo
- socket2

### Flutter (Client)
- http
- flutter/material

