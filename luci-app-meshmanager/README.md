# luci-app-meshmanager 1.1.0

LuCI Mesh Manager cho OpenWrt: Controller/Agent, đồng bộ Wi-Fi 2.4GHz và 5GHz, 802.11r/k/v, Smart Roaming theo RSSI, trạng thái node/client và lịch sử chuyển AP.

## Thành phần chính

- Controller / Agent với heartbeat mặc định 5 giây.
- Agent tự lấy revision mới khi online hoặc khi Controller đổi cấu hình.
- Shared config: SSID, key, encryption, 802.11r/k/v, Mobility Domain và Smart Roaming.
- Local config: channel, channel width và TX power của từng node không bị Controller ghi đè.
- Agent ở chế độ `Controller Managed` khóa các trường Wi-Fi shared trong LuCI.
- Smart Roaming gửi 802.11v BSS Transition Request khi RSSI thấp hơn ngưỡng.
- Cooldown + minimum dwell để giảm ping-pong.
- Forced disconnect ở Critical RSSI có sẵn nhưng mặc định TẮT để hạn chế gián đoạn phiên TCP/video/copy file.
- Controller ghi nhận AP transition thực tế khi cùng một MAC xuất hiện ở node khác qua heartbeat.
- Node status gồm 2.4/5GHz client count, backhaul, RSSI backhaul (nếu là wireless), revision và last_seen.
- Controller mất kết nối không xóa cấu hình Agent; Agent tiếp tục phát Wi-Fi với cấu hình cuối cùng.

## Build vào OpenWrt

Chép thư mục package vào source tree:

    openwrt/package/luci-app-meshmanager

Sau đó:

    make menuconfig

Chọn:

    LuCI -> Applications -> luci-app-meshmanager

Build riêng:

    make package/luci-app-meshmanager/compile V=s

## Cấu hình Controller

1. Network -> Mesh Manager -> Nâng cao.
2. Chọn `Controller`.
3. ĐỔI `Shared Token` mặc định `change-me-now`.
4. Lưu & Áp dụng.
5. Cấu hình Wi-Fi 2.4GHz, 5GHz, Fast Roaming và Smart Roaming.

Mỗi lần `Lưu & Áp dụng` các mục Wi-Fi/roaming, Controller tăng `config_version`; Agent online nhận revision mới ở heartbeat tiếp theo.

## Cấu hình Agent

1. Cài cùng package.
2. Nâng cao -> Vai trò `Agent`.
3. Điền Controller IP. Có thể để trống nếu gateway LAN chính là Controller.
4. Shared Token phải giống Controller.
5. Bật `Controller Managed`.
6. Lưu & Áp dụng.

Agent tự pull shared config, ghi UCI wireless và reload Wi-Fi khi revision thay đổi.

## Cấu hình roaming khuyến nghị ban đầu

- 802.11r: bật
- 802.11k: bật
- 802.11v: bật
- FT over DS: tắt (FT over Air)
- Roaming RSSI: -67 dBm
- Critical RSSI: -75 dBm
- Minimum dwell: 10 giây
- Cooldown: 15 giây
- Forced disconnect: tắt

Sau đó tinh chỉnh theo thực tế vùng phủ sóng và loại client.

## Cơ chế Smart Roaming

Khi client đã bám AP đủ `minimum dwell` và RSSI thấp hơn `roaming_rssi`, daemon thử:

1. `ubus call hostapd.<ifname> bss_transition_request`
2. Nếu firmware không expose ubus method đó, fallback sang `hostapd_cli ... bss_tm_req`.

Thiết bị client vẫn là bên quyết định AP đích. Đây là đúng với cơ chế 802.11v; Controller không thể bảo đảm mọi điện thoại/laptop sẽ chuyển AP tại cùng một RSSI.

`force_disconnect=1` chỉ nên dùng sau khi test thiết bị vì nó có thể tạo ngắt quãng khi client không hỗ trợ roaming tốt.

## Không mất IP khi roaming

Để phiên tải file/video/TCP tiếp tục tốt nhất, Controller và Agent phải nằm cùng Layer-2 LAN/bridge và client giữ cùng subnet/DHCP domain. 802.11r giảm thời gian xác thực nhưng không thể cam kết 0 packet loss trên mọi client/driver.

## Mesh Backhaul

Trang Mesh Backhaul lưu chính sách/backhaul profile và hiển thị trạng thái. Bản 1.1.0 KHÔNG tự ý tạo lại bridge/STP hay ép chuyển topology Ethernet <-> 802.11s vì thao tác này phụ thuộc thiết kế mạng/router và có thể tạo loop Layer-2. Nếu ROM của bạn đã có 802.11s/Ethernet backhaul, Mesh Manager sẽ không phá topology đó.

## Bảo mật

Controller API dùng token và được bind vào địa chỉ LAN tại thời điểm service khởi động. API hiện dùng HTTP nội bộ, vì vậy:

- chỉ dùng trong LAN tin cậy;
- đổi token mặc định ngay;
- không NAT/port-forward TCP 17891 ra Internet;
- nếu LAN có user không tin cậy, nên tách management VLAN hoặc bổ sung TLS.

## Yêu cầu package

`luci-base`, `rpcd`, `rpcd-mod-file`, `jsonfilter`, `curl`, `iwinfo`, `hostapd-common`, `hostapd-utils`, `uhttpd`.

## Gỡ lỗi

    logread -e meshmanager
    /etc/meshmanager/agent.sh once
    /etc/meshmanager/node-status.sh
    /etc/meshmanager/clients.sh
    /etc/meshmanager/smart-roaming.sh tick
    ubus call meshmanager status
    ubus call meshmanager nodes
    ubus call meshmanager history

