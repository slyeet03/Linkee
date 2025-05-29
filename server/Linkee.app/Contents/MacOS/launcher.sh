#!/bin/bash

# Resolve full path to the binary
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY_PATH="$SCRIPT_DIR/server"

# Launch Terminal and run the binary using full path
osascript <<END
tell application "Terminal"
    activate
    do script "cd \"$SCRIPT_DIR\"; \"$BINARY_PATH\""
end tell
END
