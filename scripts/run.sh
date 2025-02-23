#!/bin/sh

venvdir=.venv3

if [ "$1" = "--clean" ]
then
    rm -rf $venvdir
    shift
fi

if [ ! -d $venvdir ]
then
    /usr/bin/python3 -m venv $venvdir
    . $venvdir/bin/activate

    # Getting a viable virtual environment was hard work, and involved looking 
    # at the pages listed in the next three comments.

    # https://github.com/vext-python/vext/issues/95 also #82, #83, #67
    # The fix for these turned out to be that there are no released PyPi packages which 
    # work with up to date versions of the declared dependencies of vext and/or vext.gi, 
    # so we need to build from a specific commits on the unreleased master branches.
    pip install --no-binary=vext https://github.com/vext-python/vext/archive/32ad4d1.zip
    pip install --no-binary=vext.gi https://github.com/vext-python/vext.gi/archive/c7a8350.zip

    # https://stackoverflow.com/questions/79138002/no-module-named-gi-after-building-onefile-executable-with-pyinstaller
    # Neither BLE_GATT nor vext.gi declares a dependency on PyGOBject, but it turns out that 
    # installing it is necessary to avoid failing with "'No module named 'gi'"
    pip install PyGObject

    # https://stackoverflow.com/questions/69919970/no-module-named-distutils-util-but-distutils-is-installed
    # At one point the first run of BLE_GATT was failing on an import referencing distutils.
    # This was not fixed by adding a pip dependency, but by running 'sudo apt install setuptools'
    # to add them to the OS's base python installation.

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




