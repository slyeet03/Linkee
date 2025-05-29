# Linkee

A cross-platform remote control application that turns your mobile device into a wireless mouse, keyboard, and media controller for your computer.

## Overview

**Linkee** has two parts:

- **Flutter Client**: A mobile app (Android APK) providing touch-based controls  
- **Rust Server**: A lightweight native app (macOS `.app` in `.dmg`) that runs on your computer and receives commands

## Features

### Mouse Control
- Touch trackpad with gesture-based movement
- Left, right, middle mouse button support
- Smooth, responsive control with adjustable sensitivity

### Keyboard Input
- Full text typing
- Special keys (arrows, function keys)
- Modifier keys (Cmd, Ctrl, Alt, Shift) with visual state indicators
- Key combos and shortcuts

### Media Controls
- Play/Pause
- Next/Previous track
- Universal media key simulation

### Volume Control
- Volume up/down
- Mute/unmute toggle

### Auto-Discovery
- Detects the server automatically on local Wi-Fi
- Manual IP entry fallback
- Real-time connection status

---

## Download

### [Releases](https://github.com/slyeet03/linkee/releases)

| Platform | File | Notes |
|---------|------|-------|
| **Android** | `linkee.apk` | Install on your mobile device |
| **macOS** | `Linkee.dmg` | Mount and install the server |


## Setup Instructions

### On Your Mac

1. Download `Linkee.dmg` from the releases section  
2. Open and drag `Linkee.app` to your Applications folder  
3. **Run `Linkee.app` — it will run in background and start the server**  
4. On first run, macOS will ask for:  
   - **Accessibility Permissions** – grant access to control mouse/keyboard  
     - Go to: `System Settings > Privacy & Security > Accessibility`  
     - Add both **Linkee.app**  
   - **⚠️ Important:** After enabling, **restart your Mac**  
5. The server will run on `http://<your-ip>:8000`

> Note: The app may take a few seconds to appear as "connected" on the mobile app after starting the server — especially on first-time use.

### On Your Android Device

1. Install the `linkee.apk`  
2. Open the app  
3. Wait for auto-discovery to detect the server (can take ~5–10 seconds)  
4. If that fails, manually enter your Mac’s IP address (shown in Terminal window when server runs)  
5. You're good to go! Use the bottom navigation to switch between mouse, keyboard, media, and volume modes

## Troubleshooting

### Connection Issues?
- Ensure both devices are on the **same Wi-Fi network**  
- Restart both the app and the server  
- Manually enter the IP if auto-discovery doesn’t work  
- Check macOS firewall settings: allow incoming connections to `Linkee.app`

### Accessibility Not Working?
- Go to **System Settings > Privacy & Security > Accessibility**  
- Ensure both **Linkee.app** are checked  
- **Restart your Mac** after granting permissions

## 🧰 Developer Info

### Server (Rust)
- Axum, Tokio, Enigo, Serde, Tracing  
- HTTP-based REST API (port `8000`)  
- Lightweight and async

### Client (Flutter)
- Cross-platform (Android/iOS)  
- Modular UI  
- Uses HTTP + JSON for all communication

## 🔧 Project Structure
linkee/
├── client/ # Flutter mobile app
├── server/ # Rust server app (macOS .app output)
└── README.md

## License

Open source — see `LICENSE` file.

