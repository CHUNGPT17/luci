# Install from a custom OpenWrt feed

This package is intended to be stored directly inside a custom feed, for example:

    <your-feed-repository>/luci-app-meshmanager/Makefile

After `./scripts/feeds update x`, the buildroot should contain:

    feeds/x/luci-app-meshmanager/Makefile

The Makefile intentionally uses:

    include $(TOPDIR)/feeds/luci/luci.mk

Do not replace it with `include ../../luci.mk` unless the package is moved into
`feeds/luci/applications/luci-app-meshmanager/` inside a full LuCI source tree.

Recommended commands:

    ./scripts/feeds update x
    ./scripts/feeds install -f -p x luci-app-meshmanager
    rm -rf tmp
    make defconfig
    ./scripts/feeds search meshmanager
    make menuconfig

In menuconfig search for `meshmanager`. It should appear under LuCI > Applications.

Avoid spaces in package directory names. Use `luci-app-meshmanager`, not names such
as `luci-app-meshmanager 2` or `luci-app-meshmanager-1.1.0 2`.
