import binascii
import sys
import time

import BLE_GATT
from gi.repository import GLib

# UUIDs
hogp_service = '90559580-b707-11ee-acb1-7b7e30f1af54' # not used at present
hogp_send = '820a7e34-4e0a-4f90-8520-04ebce35a3a1'
hogp_recv = '1017adcc-dcbc-4387-a59f-2546b2ea5bb0'

def sync_example(mmp_address,cmd):
    mmp = BLE_GATT.Central(mmp_address)
    mmp.connect()
    time.sleep(5.000)
    print(mmp.chrcs.keys())
    mmp.char_write(hogp_send, cmd1)
    time.sleep(5.000)
    print(mmp.char_read(hogp_recv))
    time.sleep(5.000)
    mmp.disconnect()

def notify_handler(value):
    print(f"Received: {bytes(value).decode('UTF-8')}")

def send_value(mmp, value):
    print('sending: ', value)
    mmp.char_write(hogp_send, value)
    return True

def async_example(mmp_address,cmd):
    mmp = BLE_GATT.Central(mmp_address)
    mmp.connect()
    mmp.on_value_change(hogp_recv, notify_handler)
    GLib.timeout_add_seconds(20, send_value)
    mmp.wait_for_notifications()    


if __name__ == "__main__":
    mmp_address=sys.argv[1]
    cmd1 = binascii.a2b_hex("35:00:02:1a:00".replace(":",""))
    async_example(mmp_address, cmd1)

    