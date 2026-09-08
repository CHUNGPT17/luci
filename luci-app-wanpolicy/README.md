# luci-app-wanpolicy v2.1.0 — OpenWrt 24.10

Build-ready LuCI application for domain-based multi-WAN routing and opt-in interface watchdogs.

## Chức năng
- Không hard-code tên WAN/interface; đọc động các `config interface` từ `/etc/config/network` (trừ loopback).
- Domain Policies: chọn Primary + Backup cho từng nhóm domain.
- Nút **Add YouTube Policy** tạo sẵn domain YouTube.
- Có thể thêm, sửa, xóa từng domain thủ công.
- Đồng bộ PBR với `dnsmasq.nftset`.
- Failover sang Backup khi watchdog của Primary báo unhealthy; tự failback khi Primary khỏe lại.
- Nhiều watchdog độc lập; chỉ interface có watchdog đang bật mới được ping.
- Mỗi watchdog có nhiều IP ping; chỉ cần một IP trả lời là thành công.
- Mặc định: 10 giây/lần, lỗi 3 lần liên tiếp thì restart logical interface bằng ubus.
- Không giới hạn số lần restart: cứ đủ số lần ping lỗi liên tiếp đã cấu hình (mặc định 3) thì restart interface, reset bộ đếm và tiếp tục giám sát.
- Trang Status & Logs tự refresh.

## Domain preset YouTube
`youtube.com`, `youtu.be`, `googlevideo.com`, `ytimg.com`, `youtubei.googleapis.com`, `youtube.googleapis.com`

## Build vào ROM OpenWrt 24.10
```sh
cd <openwrt-source>
cp -a luci-app-wanpolicy package/luci-app-wanpolicy
make menuconfig
```
Chọn `LuCI -> Applications -> luci-app-wanpolicy`.

Để domain routing bằng `dnsmasq.nftset`, ROM cần dnsmasq có hỗ trợ nftset (thường dùng `dnsmasq-full`) và `pbr`.

Build riêng package:
```sh
make package/luci-app-wanpolicy/compile V=s
```

Menu LuCI:
- Network -> WAN Policy -> Domain Policies
- Network -> WAN Policy -> Interface Watchdog
- Network -> WAN Policy -> Status & Logs

## Lưu ý
- Interface không có watchdog sẽ không bị app ping hoặc restart.
- Failover/failback thay đổi public NAT IP nên phiên TCP/QUIC đang tồn tại có thể reconnect; kết nối mới sẽ theo policy mới.
- Routing theo domain phụ thuộc việc dnsmasq/PBR nhìn thấy DNS resolution; DoH/DoT bên ngoài router có thể làm thiếu IP trong nftset.
