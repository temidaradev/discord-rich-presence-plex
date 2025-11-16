#!/bin/bash
echo "========================================"
echo "Plex Discord RPC - macOS Installation"
echo "========================================"
echo ""

CURRENT_USER=$(whoami)
HOME_DIR=$(eval echo ~$CURRENT_USER)

PROJECT_DIR="$HOME_DIR/Documents/discord-rich-presence-plex"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Error: Project directory not found: $PROJECT_DIR"
    echo "Please ensure the project is cloned to the correct location."
    exit 1
fi

echo "✓ Project directory found: $PROJECT_DIR"

if [ ! -d "$PROJECT_DIR/venv" ]; then
    echo "❌ Error: Virtual environment not found."
    echo "Please run 'python3 -m venv venv' first."
    exit 1
fi

echo "✓ Virtual environment found"

LAUNCH_AGENTS_DIR="$HOME_DIR/Library/LaunchAgents"

mkdir -p "$LAUNCH_AGENTS_DIR"

cat > "$LAUNCH_AGENTS_DIR/com.plex.discord-rpc.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.plex.discord-rpc</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>$PROJECT_DIR/venv/bin/python</string>
        <string>$PROJECT_DIR/main.py</string>
    </array>
    
    <key>WorkingDirectory</key>
    <string>$PROJECT_DIR</string>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>KeepAlive</key>
    <true/>
    
    <key>StandardOutPath</key>
    <string>/tmp/plex-discord-rpc.log</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/plex-discord-rpc.error.log</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF

echo "✓ Launch Agent created"

launchctl unload "$LAUNCH_AGENTS_DIR/com.plex.discord-rpc.plist" 2>/dev/null
launchctl load "$LAUNCH_AGENTS_DIR/com.plex.discord-rpc.plist"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation completed!"
    echo ""
    echo "The program is now running and will start automatically on every macOS boot."
    echo ""
    echo "📝 Useful Commands:"
    echo ""
    echo "  # Stop the program:"
    echo "  launchctl unload ~/Library/LaunchAgents/com.plex.discord-rpc.plist"
    echo ""
    echo "  # Start the program:"
    echo "  launchctl load ~/Library/LaunchAgents/com.plex.discord-rpc.plist"
    echo ""
    echo "  # View logs:"
    echo "  tail -f /tmp/plex-discord-rpc.log"
    echo ""
    echo "  # View error logs:"
    echo "  tail -f /tmp/plex-discord-rpc.error.log"
    echo ""
else
    echo ""
    echo "❌ An error occurred during installation."
    echo "Please check the error messages."
    exit 1
fi
