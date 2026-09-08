#!/bin/sh
. /etc/meshmanager/lib.sh
apply_band(){
	band="$1"; sec="$2"; radio="$(mm_find_radio "$band")"; [ -n "$radio" ] || { mm_log "No $band radio found"; return 0; }
	iface=""
	for s in $(uci show wireless 2>/dev/null | sed -n 's/^wireless\.\([^.=]*\)=wifi-iface.*/\1/p'); do
		[ "$(uci -q get wireless.$s.device)" = "$radio" ] || continue
		[ "$(uci -q get wireless.$s.mode)" = ap ] || continue
		iface="$s"; break
	done
	if [ -z "$iface" ]; then
		iface="mm_${band}_ap"
		uci set wireless.$iface=wifi-iface
		uci set wireless.$iface.device="$radio"
		uci set wireless.$iface.mode='ap'
		uci set wireless.$iface.network='lan'
	fi
	uci set wireless.$iface.ssid="$(uci -q get meshmanager.$sec.ssid)"
	uci set wireless.$iface.encryption="$(uci -q get meshmanager.$sec.encryption)"
	uci set wireless.$iface.key="$(uci -q get meshmanager.$sec.key)"
	[ "$(uci -q get meshmanager.$sec.enabled)" = 1 ] && uci -q delete wireless.$iface.disabled || uci set wireless.$iface.disabled='1'

	# Channel/width/txpower are local per node and are NOT pulled from Controller.
	channel="$(uci -q get meshmanager.$sec.channel)"
	htmode="$(uci -q get meshmanager.$sec.htmode)"
	txpower="$(uci -q get meshmanager.$sec.txpower)"
	[ -n "$channel" ] && uci set wireless.$radio.channel="$channel"
	[ -n "$htmode" ] && uci set wireless.$radio.htmode="$htmode"
	if [ -n "$txpower" ]; then uci set wireless.$radio.txpower="$txpower"; else uci -q delete wireless.$radio.txpower; fi

	r="$(uci -q get meshmanager.roaming.ieee80211r)"; k="$(uci -q get meshmanager.roaming.ieee80211k)"; v="$(uci -q get meshmanager.roaming.ieee80211v)"
	[ "$(uci -q get meshmanager.roaming.enabled)" = 1 ] || { r=0; k=0; v=0; }
	uci set wireless.$iface.ieee80211r="$r"
	uci set wireless.$iface.mobility_domain="$(uci -q get meshmanager.roaming.mobility_domain)"
	uci set wireless.$iface.ft_over_ds="$(uci -q get meshmanager.roaming.ft_over_ds)"
	uci set wireless.$iface.ft_psk_generate_local='1'
	uci set wireless.$iface.ieee80211k="$k"
	uci set wireless.$iface.rrm_neighbor_report="$k"
	uci set wireless.$iface.rrm_beacon_report="$k"
	uci set wireless.$iface.ieee80211v="$v"
	uci set wireless.$iface.bss_transition="$v"
}
apply_band 2g wifi24
apply_band 5g wifi5
uci commit wireless
wifi reload
