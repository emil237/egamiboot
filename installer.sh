#!/bin/sh
echo "install plugin egamiboot"
cd /tmp
curl  -k -Lbk -m 55532 -m 555104 "https://raw.githubusercontent.com/emil237/egamiboot/refs/heads/main/enigma2-plugin-extensions-egamiboot_10.5.ipk" > /tmp/enigma2-plugin-extensions-egamiboot_10.5.ipk
sleep 1
echo "install plugin...."
cd /tmp
opkg install /tmp/enigma2-plugin-extensions-egamiboot_10.5.ipk
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
sleep 1
rm /tmp/enigma2-plugin-extensions-egamiboot_10.5.ipk
sleep 2
killall -9 enigma2
exit
