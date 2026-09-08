#!/bin/sh
. /etc/meshmanager/lib.sh
find_controller(){
	c="$(uci -q get meshmanager.main.controller_ip)"
	[ -n "$c" ] && { echo "$c"; return; }
	ubus call network.interface.lan status 2>/dev/null | jsonfilter -e '@.route[@.target="0.0.0.0"].nexthop' | head -n1
}
pull_field(){ val="$(jsonfilter -i "$1" -e "$2")"; [ -n "$val" ] && uci set "$3=$val"; }
pull_once(){
	c="$(find_controller)"; [ -n "$c" ] || return 1
	p="$(uci -q get meshmanager.main.controller_port || echo 17891)"; token="$(mm_token)"
	mkdir -p /tmp/meshmanager; tmp=/tmp/meshmanager/controller.json
	curl -fsS --connect-timeout 2 -H "X-Mesh-Token: $token" "http://$c:$p/config" -o "$tmp" || return 1
	cv="$(jsonfilter -i "$tmp" -e '@.version')"; lv="$(mm_version)"; [ -n "$cv" ] || return 1
	[ "$cv" = "$lv" ] && return 0
	for sec in wifi24 wifi5; do
		pull_field "$tmp" "@.$sec.enabled" "meshmanager.$sec.enabled"
		ssid="$(jsonfilter -i "$tmp" -e "@.$sec.ssid")"; enc="$(jsonfilter -i "$tmp" -e "@.$sec.encryption")"; key="$(jsonfilter -i "$tmp" -e "@.$sec.key")"
		uci set "meshmanager.$sec.ssid=$ssid"; uci set "meshmanager.$sec.encryption=$enc"; uci set "meshmanager.$sec.key=$key"
	done
	for x in enabled r k v mobility_domain ft_over_ds; do
		case "$x" in r) dst=ieee80211r;; k) dst=ieee80211k;; v) dst=ieee80211v;; *) dst="$x";; esac
		val="$(jsonfilter -i "$tmp" -e "@.roaming.$x")"; [ -n "$val" ] && uci set "meshmanager.roaming.$dst=$val"
	done
	for x in enabled roaming_rssi critical_rssi min_dwell cooldown prefer_5g prevent_pingpong bss_transition force_disconnect apply_24 apply_5; do
		val="$(jsonfilter -i "$tmp" -e "@.smart.$x")"; [ -n "$val" ] && uci set "meshmanager.smart.$x=$val"
	done
	uci set meshmanager.main.config_version="$cv"
	uci commit meshmanager
	if /etc/meshmanager/apply.sh; then
		date '+%F %T' > /tmp/meshmanager/last_sync
		mm_log "Synced config v$cv from $c"
	else
		mm_log "Failed applying config v$cv from $c"
		return 1
	fi
}
heartbeat(){
	c="$(find_controller)"; [ -n "$c" ] || return 1
	p="$(uci -q get meshmanager.main.controller_port || echo 17891)"; token="$(mm_token)"
	/etc/meshmanager/node-status.sh > /tmp/meshmanager/local-status.json
	curl -fsS --connect-timeout 2 -H "X-Mesh-Token: $token" -H 'Content-Type: application/json' --data-binary @/tmp/meshmanager/local-status.json "http://$c:$p/heartbeat" >/dev/null 2>&1
}
tick(){ pull_once; heartbeat; /etc/meshmanager/smart-roaming.sh tick >/dev/null 2>&1; }
case "$1" in once) tick;; *) while true; do tick; sleep "$(uci -q get meshmanager.main.heartbeat || echo 5)"; done;; esac
