#!/bin/sh
. /etc/meshmanager/lib.sh
publish(){
	v="$(uci -q get meshmanager.main.config_version || echo 1)"; v=$((v+1))
	uci set meshmanager.main.config_version="$v"; uci commit meshmanager
	mm_log "Published config v$v"
}
cleanup(){
	mkdir -p /tmp/meshmanager/nodes
	now="$(date +%s)"; timeout="$(uci -q get meshmanager.main.offline_timeout || echo 15)"
	# Keep offline nodes visible for 7 days; only remove very stale runtime records.
	maxage=604800
	for f in /tmp/meshmanager/nodes/*.json; do
		[ -e "$f" ] || continue
		last="$(jsonfilter -i "$f" -e '@.last_seen')"; [ -n "$last" ] || continue
		[ $((now-last)) -lt "$maxage" ] || rm -f "$f"
	done
}
case "$1" in
 sync|publish) publish;;
 discover) mm_log "Discovery requested; Agents register automatically by heartbeat";;
 *) mkdir -p /tmp/meshmanager; while true; do /etc/meshmanager/smart-roaming.sh tick >/dev/null 2>&1; cleanup; sleep "$(uci -q get meshmanager.main.heartbeat || echo 5)"; done;;
esac
