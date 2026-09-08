#!/bin/sh
printf '{"version":"%s","last_sync":"%s"}\n' "$(uci -q get meshmanager.main.config_version || echo 1)" "$(cat /tmp/meshmanager/last_sync 2>/dev/null)"
