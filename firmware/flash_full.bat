@echo off
rem ESP32 WireGuard relay - full flash to COM9.
rem Enter download mode first: hold BOOT, tap RST, hold BOOT ~3s, release.
setlocal
set "PORT=COM9"
python -m esptool --chip esp32 -p %PORT% -b 460800 --before no_reset --after hard_reset write_flash --flash_mode dio --flash_freq 40m --flash_size 4MB 0x1000 bootloader.bin 0x8000 partition-table.bin 0xd000 ota_data_initial.bin 0x10000 esp32dn4_wg_relay.bin
if errorlevel 1 goto :fail
echo FLASH_OK
exit /b 0
:fail
echo FLASH_FAILED
exit /b 1
