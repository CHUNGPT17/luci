# 1.1.0

- Hoàn thiện Smart Roaming engine bằng 802.11v BSS Transition Request.
- Fallback hostapd_cli khi hostapd ubus không hỗ trợ request.
- Minimum dwell, cooldown, critical RSSI và forced disconnect tùy chọn.
- Agent đồng bộ cả Smart Roaming profile.
- Controller tự tăng revision khi Save & Apply Wi-Fi/roaming.
- Agent giữ channel/htmode/txpower cục bộ.
- Thêm Clients và Roaming History trong LuCI.
- Heartbeat JSON mở rộng: client count, BSSID, backhaul và client list.
- Ghi nhận client chuyển Node dựa trên heartbeat.
- Agent Managed: các trường shared chuyển read-only.
- API Controller bind vào LAN IP thay vì mặc định 0.0.0.0 khi xác định được IP LAN.
