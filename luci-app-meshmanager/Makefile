include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for Mesh Manager
LUCI_DEPENDS:= \
	+luci-base \
	+rpcd \
	+rpcd-mod-file \
	+jsonfilter \
	+curl \
	+iwinfo \
	+hostapd-common \
	+hostapd-utils \
	+uhttpd

LUCI_PKGARCH:=all

PKG_VERSION:=1.1.0
PKG_RELEASE:=3
PKG_MAINTAINER:=CHUNGPT17

# This package lives in a custom OpenWrt feed (for example feeds/x/),
# so include LuCI's build helper through TOPDIR rather than ../../luci.mk.
include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
