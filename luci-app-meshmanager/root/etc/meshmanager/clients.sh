#!/bin/sh
mkdir -p /tmp/meshmanager
raw=/tmp/meshmanager/clients.raw
: > "$raw"
for ifc in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
	type="$(iw dev "$ifc" info 2>/dev/null | awk '$1=="type"{print $2; exit}')"
	[ "$type" = AP ] || continue
	freq="$(iw dev "$ifc" info 2>/dev/null | awk '$1=="channel"{gsub(/\(/,"",$3); print $3; exit}')"
	band=2g
	case "$freq" in ''|*[!0-9]*) band=unknown;; *) [ "$freq" -ge 4900 ] && band=5g;; esac
	iw dev "$ifc" station dump 2>/dev/null | awk -v IF="$ifc" -v BAND="$band" '
		/^Station /{if(mac!="") print mac"|"IF"|"BAND"|"sig"|"tx"|"rx; mac=$2; sig=""; tx=""; rx=""}
		/^[[:space:]]*signal:/{sig=$2}
		/^[[:space:]]*tx bitrate:/{tx=$3" "$4}
		/^[[:space:]]*rx bitrate:/{rx=$3" "$4}
		END{if(mac!="") print mac"|"IF"|"BAND"|"sig"|"tx"|"rx}
	' >> "$raw"
done
printf '['
first=1
while IFS='|' read -r mac iface band sig tx rx; do
	[ -n "$mac" ] || continue
	[ "$first" -eq 1 ] || printf ','
	first=0
	printf '{"mac":"%s","ifname":"%s","band":"%s","signal":%s,"tx":"%s","rx":"%s"}' "$mac" "$iface" "$band" "${sig:--127}" "$tx" "$rx"
done < "$raw"
printf ']\n'
