#!/bin/sh
. /etc/meshmanager/lib.sh
json_escape(){ printf '%s' "$1" | sed 's/\\/\\\\/g;s/"/\\"/g'; }
clients="$(/etc/meshmanager/clients.sh)"
backhaul="$(/etc/meshmanager/backhaul-status.sh)"
c24="$(printf '%s' "$clients" | jsonfilter -e '@[*].band' 2>/dev/null | grep -c '^2g$')"
c5="$(printf '%s' "$clients" | jsonfilter -e '@[*].band' 2>/dev/null | grep -c '^5g$')"
b24=""; b5=""
for ifc in $(mm_ap_ifaces); do
	band="$(mm_band_for_if "$ifc")"; mac="$(iw dev "$ifc" info 2>/dev/null | awk '$1=="addr"{print $2; exit}')"
	[ "$band" = 2g ] && b24="$mac"
	[ "$band" = 5g ] && b5="$mac"
done
bt="$(printf '%s' "$backhaul" | jsonfilter -e '@.type')"; bi="$(printf '%s' "$backhaul" | jsonfilter -e '@.ifname')"; bs="$(printf '%s' "$backhaul" | jsonfilter -e '@.signal')"
printf '{"id":"%s","name":"%s","ip":"%s","version":"%s","time":%s,"clients24":%s,"clients5":%s,"bssid24":"%s","bssid5":"%s","backhaul":"%s","backhaul_if":"%s","backhaul_signal":%s,"clients":%s}\n' \
 "$(mm_node_id)" "$(json_escape "$(mm_node_name)")" "$(mm_lan_ip)" "$(mm_version)" "$(mm_epoch)" "${c24:-0}" "${c5:-0}" "$b24" "$b5" "$bt" "$bi" "${bs:-0}" "$clients"
