ESP32 WireGuard 中继固件 · 导出包
日期：2026-10-30
芯片：ESP32-D0WD-V3（经典 ESP32），Flash 4MB，双 OTA 分区
构建：ESP-IDF v5.3.2

==================== 文件说明 ====================

firmware/
  esp32dn4_wg_relay.bin        应用镜像（839,632 字节），用于网页 OTA 上传
  bootloader.bin               写 0x1000
  partition-table.bin          写 0x8000
  ota_data_initial.bin         写 0xD000（把启动槽重置到 ota_0）
  flash_full.bat               串口烧录全部 4 个文件（不覆盖 NVS）

source/
  esp32dn4_wg_relay_src.zip    完整源码（含 vendored esp_wireguard 组件）

==================== 串口烧录 ====================

1) 进入下载模式：按住 BOOT(IO0) → 点一下 RST(EN) → 松开 RST 后
   继续按住 BOOT 约 3 秒 → 松开
2) 双击 firmware\flash_full.bat（默认 COM9，可改脚本里的 PORT）
   成功会打印 FLASH_OK。

NVS 在 0x9000~0xD000，这个脚本不会写该区域，WiFi / WireGuard 配置保留。

手工命令（在 firmware 目录）：
  python -m esptool --chip esp32 -p COM9 -b 460800 --before no_reset ^
    --after hard_reset write_flash --flash_mode dio --flash_freq 40m ^
    --flash_size 4MB 0x1000 bootloader.bin 0x8000 partition-table.bin ^
    0xd000 ota_data_initial.bin 0x10000 esp32dn4_wg_relay.bin

==================== OTA 升级 ====================

手机连热点 ESP32-RELAY → 打开 http://192.168.4.1/ → “固件升级(OTA)”
→ 选择 firmware\esp32dn4_wg_relay.bin → 上传。
新固件启动失败会自动回滚到旧版本。

==================== 源码编译 ====================

安装 ESP-IDF v5.3.2，解压 source\esp32dn4_wg_relay_src.zip，然后：
  idf.py set-target esp32
  idf.py build
产物：build/esp32dn4_wg_relay.bin

==================== 使用要点 ====================

1. 设备重启后必须打开一次网页（自动用浏览器时间校时），
   WireGuard 才会启动；状态页“握手=已握手”才代表隧道真正可用。
2. 保存 WireGuard 参数会重启设备（预期行为，避免原地重建网卡
   破坏转发）；页面 12 秒后自动刷新并重新校时。
3. MTU 推荐 1280（允许 576~1420）。固件会自动按 MTU 钳制客户端
   TCP MSS，不依赖路径 MTU 探测。
4. 服务端 [Peer] 的 AllowedIPs 要包含 隧道地址/32（如 10.66.66.3/32），
   并开启 ip_forward + MASQUERADE。

Complete with AI
