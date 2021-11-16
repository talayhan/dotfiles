## Reference: https://linuxreviews.org/Realtek_RTL8761B

## Linux Support

The RTL8791B dongle chip has been supported by the bt_rtl (CONFIG_BT_RTL) driver since Linux 5.8.

You will need to upgrade your kernel to 5.8+ if you have an older kernel and you want to use this dongle.

CONFIG_BT_RTL is not listed as its own item in menuconfig in Linux 5.11, which can be a bit confusing. You should choose Networking support ▸ Bluetooth subsystem support ▸ Bluetooth device drivers ▸ HCI USB driver and the two options both named Realtek protocol support in that same menu (BT_HCIBTUSB_RTL and BT_HCIUART_RTL). You will then find that BT_RTL is enabled if you press / and search for BT_RTL.

The driver requires firmware. The firmware package shipped with most GNU/Linux distributions tend to just provide a /lib/firmware/rtl_bt/rtl8761a_fw.bin file for the RTL8761A model.

The firmware files for the RTL8761B can be acquired from the github.com/Realtek-OpenSource/android_hardware_realtek firmware repository using these links:

    https://raw.githubusercontent.com/Realtek-OpenSource/android_hardware_realtek/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_config
    https://raw.githubusercontent.com/Realtek-OpenSource/android_hardware_realtek/rtk1395/bt/rtkbt/Firmware/BT/rtl8761b_fw

These firmware files need to be copied and renamed to:

```
    /usr/lib/firmware/rtl_bt/rtl8761b_fw.bin OR /lib/firmware/rtl_bt/rtl8761b_fw.bin
    /usr/lib/firmware/rtl_bt/rtl8761b_config.bin OR /lib/firmware/rtl_bt/rtl8761b_config.bin
```

It does not matter which location you copy the firmware files to on most distributions. Fedora and many others have a symbolic link from /lib/ to /usr/lib (making them the same folder).

Something called "Arch" has these firmware files available as a package called rtl8761b-fw (aur: rtl8761b-fw).
