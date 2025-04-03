#!/bin/sh

set -e  
echo "Installing plugin EGAMIBoot..."
PLUGIN_URL="https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/enigma2-plugin-extensions-egamiboot_10.6+git36664+9046a020+9046a0294b-r0_all.ipk"
PLUGIN_FILE="/tmp/enigma2-plugin-extensions-egamiboot_10.6+git36664+9046a020+9046a0294b-r0_all.ipk"
TARGET_PATH="/usr/lib/enigma2/python/Plugins/Extensions/EGAMIBoot"

curl -k -L -m 55532 "$PLUGIN_URL" -o "$PLUGIN_FILE"
sleep 1

echo "Installing plugin..."
opkg install --force-reinstall --force-depends "$PLUGIN_FILE"
sleep 1

if [ -d "$TARGET_PATH" ]; then
    echo "Setting permissions for: $TARGET_PATH"
    chmod -R 755 "$TARGET_PATH"
    echo "Permissions changed successfully."
else
    echo "Error: The path $TARGET_PATH does not exist."
    exit 1
fi

rm -f "$PLUGIN_FILE"
sleep 2

echo "Restarting Enigma2..."
killall -9 enigma2
exit


