#!/bin/bash
echo "========================================="
echo "Plex Discord RPC - Linux Installation"
echo "========================================="
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

SYSTEMD_USER_DIR="$HOME_DIR/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

# Create systemd service file
cat > "$SYSTEMD_USER_DIR/plex-discord-rpc.service" << EOF
[Unit]
Description=Discord Rich Presence for Plex
Documentation=https://github.com/phin05/discord-rich-presence-plex
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment="DISPLAY=:0"
Environment="DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus"
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/venv/bin/python main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

echo "✓ Systemd service file created"

systemctl --user daemon-reload

systemctl --user enable plex-discord-rpc.service

systemctl --user start plex-discord-rpc.service

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Installation completed!"
    echo ""
    echo "The program is now running and will start automatically on every boot."
    echo ""
    echo "📝 Useful Commands:"
    echo ""
    echo "  # Check status:"
    echo "  systemctl --user status plex-discord-rpc.service"
    echo ""
    echo "  # Stop the program:"
    echo "  systemctl --user stop plex-discord-rpc.service"
    echo ""
    echo "  # Start the program:"
    echo "  systemctl --user start plex-discord-rpc.service"
    echo ""
    echo "  # Restart the program:"
    echo "  systemctl --user restart plex-discord-rpc.service"
    echo ""
    echo "  # View logs:"
    echo "  journalctl --user -u plex-discord-rpc.service -f"
    echo ""
    echo "  # Disable auto-start:"
    echo "  systemctl --user disable plex-discord-rpc.service"
    echo ""
else
    echo ""
    echo "❌ An error occurred during installation."
    echo "Please check the error messages."
    exit 1
fi
