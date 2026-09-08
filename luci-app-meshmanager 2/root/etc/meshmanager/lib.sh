#!/bin/sh
. /lib/functions.sh
mm_log(){ logger -t meshmanager "$*"; }
mm_role(){ uci -q get meshmanager.main.role || echo controller; }
mm_token(){ uci -q get meshmanager.main.token; }
mm_version(){ uci -q get meshmanager.main.config_version || echo 1; }
mm_lan_ip(){ ubus call network.interface.lan status 2>/dev/null | jsonfilter -e '@["ipv4-address"][0].address'; }
mm_node_id(){ cat /sys/class/net/br-lan/address 2>/dev/null | tr -d ':' || cat /etc/machine-id 2>/dev/null; }
mm_node_name(){ uci -q get meshmanager.main.node_name || uci -q get system.@system[0].hostname || echo OpenWrt-Node; }
mm_epoch(){ date +%s; }
mm_find_radio(){
	want="$1"
	for r in $(uci show wireless 2>/dev/null | sed -n 's/^wireless\.\([^.=]*\)=wifi-device.*/\1/p'); do
		band="$(uci -q get wireless.$r.band)"
		case "$want:$band" in 2g:2g|5g:5g) echo "$r"; return;; esac
	done
	[ "$want" = 2g ] && uci show wireless 2>/dev/null | sed -n 's/^wireless\.\([^.=]*\)=wifi-device.*/\1/p' | head -n1
	[ "$want" = 5g ] && uci show wireless 2>/dev/null | sed -n 's/^wireless\.\([^.=]*\)=wifi-device.*/\1/p' | sed -n '2p'
}
mm_ap_ifaces(){
	for ifc in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
		type="$(iw dev "$ifc" info 2>/dev/null | awk '$1=="type"{print $2; exit}')"
		[ "$type" = AP ] && echo "$ifc"
	done
}
mm_band_for_if(){
	freq="$(iw dev "$1" info 2>/dev/null | awk '$1=="channel"{gsub(/\(/,"",$3); print $3; exit}')"
	case "$freq" in ''|*[!0-9]*) echo unknown;; *) [ "$freq" -ge 4900 ] && echo 5g || echo 2g;; esac
}
mm_urlencode(){
	# Values sent through curl --data-urlencode do not need manual encoding.
	printf '%s' "$1"
}
