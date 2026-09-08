#!/bin/sh
. /etc/meshmanager/lib.sh
last="$(cat /tmp/meshmanager/last_sync 2>/dev/null)"
printf '{"role":"%s","ip":"%s","version":"%s","name":"%s","last_sync":"%s","smart":"%s"}\n' "$(mm_role)" "$(mm_lan_ip)" "$(mm_version)" "$(mm_node_name)" "$last" "$(uci -q get meshmanager.smart.enabled || echo 0)"
