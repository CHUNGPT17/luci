#!/bin/sh
mkdir -p /tmp/meshmanager
file=/tmp/meshmanager/roam-history.log
case "$1" in
 add)
	shift
	printf '%s\n' "$*" >> "$file"
	tail -n 200 "$file" > "$file.tmp" 2>/dev/null && mv "$file.tmp" "$file"
	;;
 json)
	printf '['; first=1
	tail -n 100 "$file" 2>/dev/null | awk '{a[NR]=$0} END{for(i=NR;i>=1;i--) print a[i]}' | while IFS='|' read -r ts mac from to oldsig newsig; do
		[ -n "$ts" ] || continue
		[ $first -eq 1 ] || printf ','; first=0
		printf '{"time":%s,"mac":"%s","from":"%s","to":"%s","old_signal":%s,"new_signal":%s}' "$ts" "$mac" "$from" "$to" "${oldsig:--127}" "${newsig:--127}"
	done
	printf ']\n'
	;;
 *) [ -f "$file" ] && cat "$file";;
esac
