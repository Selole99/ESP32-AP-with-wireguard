ESP32 WireGuard Relay Firmware - Export Package
Date: 2026-10-30
Chip: ESP32-D0WD-V3 (classic ESP32), 4 MB flash, dual OTA partitions
Built with: ESP-IDF v5.3.2

==================== Files ====================

firmware/
  esp32dn4_wg_relay.bin        Application image (839,632 bytes), for web OTA upload
  bootloader.bin               Flash at 0x1000
  partition-table.bin          Flash at 0x8000
  ota_data_initial.bin         Flash at 0xD000 (resets the boot slot to ota_0)
  flash_full.bat               Serial flash of all 4 files (does not touch NVS)

source/
  esp32dn4_wg_relay_src.zip    Full source (including the vendored esp_wireguard component)

==================== Serial Flashing ====================

1) Enter download mode: hold BOOT (IO0) -> tap RST (EN) -> release RST,
   keep holding BOOT for about 3 seconds -> release.
2) Double-click firmware\flash_full.bat (defaults to COM9; edit PORT in the script if needed).
   It prints FLASH_OK on success.

NVS lives at 0x9000-0xD000; this script does not write that region,
so WiFi / WireGuard settings are preserved.

Manual command (run inside the firmware folder):
  python -m esptool --chip esp32 -p COM9 -b 460800 --before no_reset ^
    --after hard_reset write_flash --flash_mode dio --flash_freq 40m ^
    --flash_size 4MB 0x1000 bootloader.bin 0x8000 partition-table.bin ^
    0xd000 ota_data_initial.bin 0x10000 esp32dn4_wg_relay.bin

==================== OTA Update ====================

Connect your phone to the ESP32-RELAY hotspot -> open http://192.168.4.1/ ->
"Firmware Upgrade (OTA)" -> select firmware\esp32dn4_wg_relay.bin -> upload.
If the new firmware fails to start, the device automatically rolls back
to the previous version.

==================== Building from Source ====================

Install ESP-IDF v5.3.2, unzip source\esp32dn4_wg_relay_src.zip, then:
  idf.py set-target esp32
  idf.py build
Output: build/esp32dn4_wg_relay.bin

==================== Notes ====================

1. After every reboot you must open the web page once (it syncs the device
   clock from the browser); WireGuard will not start otherwise. The tunnel
   is only truly usable when the status page shows "Handshake: Established".
2. Saving WireGuard settings reboots the device (expected behavior, to avoid
   rebuilding the network interface in place and corrupting forwarding).
   The page reloads and re-syncs the clock 12 seconds later.
3. MTU 1280 is recommended (576-1420 allowed). The firmware automatically
   clamps client TCP MSS to the MTU, so no path-MTU discovery is required.
4. The server-side [Peer] AllowedIPs must include the tunnel address /32
   (e.g. 10.66.66.3/32), with ip_forward + MASQUERADE enabled.
 Complete with AI
