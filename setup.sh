#!/bin/bash

SCRIPT="global-logrotate.sh"

sudo chmod 755 "$SCRIPT"
sudo chown root:root "$SCRIPT"
sudo cp "$SCRIPT" /usr/local/bin/global-logrotate
sudo ln -sf /usr/local/bin/"$SCRIPT" /usr/bin/"$SCRIPT" 
echo "Script installed successfully. You can run it using the command: $SCRIPT"
echo "To view the help, run: $SCRIPT -h"
echo "To run the script, use: $SCRIPT [options]"
echo "For example: $SCRIPT -H -p /var/log/myapp -f myapp.log -r 30 -n"