# Cài vào LuCI feed

Package này được đóng theo layout chuẩn của repo LuCI và Makefile dùng:

    include ../../luci.mk

Hãy đặt nguyên thư mục `luci-app-meshmanager` vào:

    luci/applications/luci-app-meshmanager/

Kết quả phải có file:

    luci/applications/luci-app-meshmanager/Makefile

Sau khi push vào branch LuCI feed, trên OpenWrt buildroot chạy:

    ./scripts/feeds update luci
    ./scripts/feeds install -f -p luci luci-app-meshmanager
    rm -rf tmp
    make defconfig
    ./scripts/feeds search meshmanager
    make menuconfig

Trong menuconfig package sẽ nằm tại:

    LuCI -> Applications -> luci-app-meshmanager
