#!/bin/bash

SCRIPT="global-logrotate"
SRC_SCRIPT="${SCRIPT}.sh"
DEST_SCRIPT="/usr/local/bin/${SCRIPT}"

# Copy the script
sudo cp "$SRC_SCRIPT" "$DEST_SCRIPT"

# Set permissions and ownership
sudo chmod 755 "$DEST_SCRIPT"
sudo chown root:root "$DEST_SCRIPT"

# Create or update symlink
sudo ln -sf "$DEST_SCRIPT" /usr/bin/"$SCRIPT"

# Success message
echo "✅ Script installed successfully!"
echo "👉 You can run it using: $SCRIPT"
echo "👉 To view help: $SCRIPT -h"
echo "👉 Example: $SCRIPT -H -p /var/log/myapp -f myapp.log -r 30 -n"
