#!/bin/sh
mesh_if=""
for ifc in $(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}'); do
	type="$(iw dev "$ifc" info 2>/dev/null | awk '$1=="type"{print $2; exit}')"
	[ "$type" = mesh ] || [ "$type" = "mesh point" ] || continue
	mesh_if="$ifc"; break
done
if [ -n "$mesh_if" ]; then
	sig="$(iw dev "$mesh_if" station dump 2>/dev/null | awk '/signal:/{if(NR==1||$2>best)best=$2}END{if(best!="")print best}')"
	printf '{"type":"wireless","ifname":"%s","signal":%s}\n' "$mesh_if" "${sig:--127}"
else
	printf '{"type":"ethernet","ifname":"","signal":0}\n'
fi
