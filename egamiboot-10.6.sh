#!/bin/sh
echo "install plugin egamiboot"
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/enigma2-plugin-extensions-egamiboot_10.6-r0_all.ipk" > /tmp/enigma2-plugin-extensions-egamiboot_10.6-r0_all.ipk
sleep 1
echo "install plugin...."
cd /tmp
opkg install /tmp/enigma2-plugin-extensions-egamiboot_10.6-r0_all.ipk
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
# Target directory
TARGET_PATH="/usr/lib/enigma2/python/Plugins/Extensions/EGAMIBoot"

# Check if the directory exists
if [ -d "$TARGET_PATH" ]; then
    echo "Changing permissions for: $TARGET_PATH"
    chmod -R 755 "$TARGET_PATH"
    echo "Permissions changed successfully."
else
    echo "The path $TARGET_PATH does not exist."
    exit 1
fi
echo ""
sleep 1
rm /tmp/enigma2-plugin-extensions-egamiboot_10.6-r0_all.ipk
sleep 2
killall -9 enigma2
exit
