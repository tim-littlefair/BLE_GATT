#!/bin/sh

venvdir=.venv3

if [ "$1" = "--clean" ]
then
    rm -rf $venvdir
fi

if [ ! -d $venvdir ]
then
    /usr/bin/python3 -m venv $venvdir
    . $venvdir/bin/activate
    pip install PyGObject
    pip install --no-binary=vext https://github.com/vext-python/vext/archive/32ad4d1.zip
    pip install --no-binary=vext.gi https://github.com/vext-python/vext.gi/archive/c7a8350.zip
    #vext -i gi.vext
    vext -i $venvdir/share/vext/specs/gi.vext
    pip install BLE_GATT
else
    . $venvdir /bin/activate
fi

target_btaddr=$1

bluetoothctl <<+
scan on
scan off
devices
connect $target_btaddr
trust $target_btaddr
disconnect $target_btaddr
exit
+
echo bluetoothctl exited

sleep 2

$venvdir/bin/python3 <<+
import time
import BLE_GATT

mmp = BLE_GATT.Central("$target_btaddr")
mmp.connect()
time.sleep(5.000)
print("MMP state:", mmp)
mmp.disconnect()
time.sleep(5.000)

+




