#!/bin/sh
. /etc/meshmanager/lib.sh
[ "$(uci -q get meshmanager.smart.enabled)" = 1 ] || exit 0
[ "$(uci -q get meshmanager.roaming.ieee80211v)" = 1 ] || exit 0
roam="$(uci -q get meshmanager.smart.roaming_rssi || echo -67)"
critical="$(uci -q get meshmanager.smart.critical_rssi || echo -75)"
dwell="$(uci -q get meshmanager.smart.min_dwell || echo 10)"
cooldown="$(uci -q get meshmanager.smart.cooldown || echo 15)"
force="$(uci -q get meshmanager.smart.force_disconnect || echo 0)"
mkdir -p /tmp/meshmanager/sta /tmp/meshmanager/roam-request
now="$(date +%s)"
request_roam(){
	ifc="$1"; mac="$2"; sig="$3"
	last="$(cat /tmp/meshmanager/roam-request/$mac 2>/dev/null || echo 0)"
	[ $((now-last)) -ge "$cooldown" ] || return 0
	# Preferred OpenWrt hostapd ubus method. Client still makes the final roaming decision.
	if ubus call "hostapd.$ifc" bss_transition_request "{\"addr\":\"$mac\"}" >/dev/null 2>&1; then
		echo "$now" > /tmp/meshmanager/roam-request/$mac
		mm_log "BSS transition requested for $mac on $ifc at ${sig}dBm"
		return 0
	fi
	# Fallback for builds exposing hostapd_cli but not the ubus method.
	if command -v hostapd_cli >/dev/null 2>&1 && hostapd_cli -i "$ifc" bss_tm_req "$mac" pref=1 >/dev/null 2>&1; then
		echo "$now" > /tmp/meshmanager/roam-request/$mac
		mm_log "BSS TM fallback requested for $mac on $ifc at ${sig}dBm"
		return 0
	fi
	return 1
}
for ifc in $(mm_ap_ifaces); do
	band="$(mm_band_for_if "$ifc")"
	[ "$band" = 2g ] && [ "$(uci -q get meshmanager.smart.apply_24)" = 1 ] || { [ "$band" != 2g ] || continue; }
	[ "$band" = 5g ] && [ "$(uci -q get meshmanager.smart.apply_5)" = 1 ] || { [ "$band" != 5g ] || continue; }
	iw dev "$ifc" station dump 2>/dev/null | awk '/^Station /{if(mac!="")print mac"|"sig;mac=$2;sig=""}/^[[:space:]]*signal:/{sig=$2}END{if(mac!="")print mac"|"sig}' | while IFS='|' read -r mac sig; do
		[ -n "$mac" ] || continue
		case "$sig" in ''|*[!0-9-]*) continue;; esac
		seen=/tmp/meshmanager/sta/$mac
		first="$(cat "$seen" 2>/dev/null || echo "$now")"
		[ -f "$seen" ] || echo "$now" > "$seen"
		[ $((now-first)) -ge "$dwell" ] || continue
		if [ "$sig" -le "$roam" ]; then request_roam "$ifc" "$mac" "$sig"; fi
		# Disabled by default because forced disconnect can interrupt traffic.
		if [ "$force" = 1 ] && [ "$sig" -le "$critical" ]; then
			ubus call "hostapd.$ifc" del_client "{\"addr\":\"$mac\",\"reason\":5,\"deauth\":false,\"ban_time\":1000}" >/dev/null 2>&1 || true
		fi
	done
done
# Remove dwell files for clients no longer associated.
for f in /tmp/meshmanager/sta/*; do
	[ -e "$f" ] || continue; mac="${f##*/}"
	found=0
	for ifc in $(mm_ap_ifaces); do iw dev "$ifc" station get "$mac" >/dev/null 2>&1 && found=1; done
	[ "$found" = 1 ] || rm -f "$f"
done
