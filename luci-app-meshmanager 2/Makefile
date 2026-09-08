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
PKG_RELEASE:=2
PKG_MAINTAINER:=CHUNGPT17

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
