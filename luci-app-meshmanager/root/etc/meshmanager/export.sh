#!/bin/sh
json_escape(){ printf '%s' "$1" | sed 's/\\/\\\\/g;s/"/\\"/g'; }
q(){ uci -q get "$1"; }
printf '{'
printf '"version":"%s",' "$(q meshmanager.main.config_version || echo 1)"
printf '"wifi24":{"enabled":"%s","ssid":"%s","encryption":"%s","key":"%s"},' "$(q meshmanager.wifi24.enabled)" "$(json_escape "$(q meshmanager.wifi24.ssid)")" "$(q meshmanager.wifi24.encryption)" "$(json_escape "$(q meshmanager.wifi24.key)")"
printf '"wifi5":{"enabled":"%s","ssid":"%s","encryption":"%s","key":"%s"},' "$(q meshmanager.wifi5.enabled)" "$(json_escape "$(q meshmanager.wifi5.ssid)")" "$(q meshmanager.wifi5.encryption)" "$(json_escape "$(q meshmanager.wifi5.key)")"
printf '"roaming":{"enabled":"%s","r":"%s","k":"%s","v":"%s","mobility_domain":"%s","ft_over_ds":"%s"},' "$(q meshmanager.roaming.enabled)" "$(q meshmanager.roaming.ieee80211r)" "$(q meshmanager.roaming.ieee80211k)" "$(q meshmanager.roaming.ieee80211v)" "$(q meshmanager.roaming.mobility_domain)" "$(q meshmanager.roaming.ft_over_ds)"
printf '"smart":{"enabled":"%s","roaming_rssi":"%s","critical_rssi":"%s","min_dwell":"%s","cooldown":"%s","prefer_5g":"%s","prevent_pingpong":"%s","bss_transition":"%s","force_disconnect":"%s","apply_24":"%s","apply_5":"%s"}' \
 "$(q meshmanager.smart.enabled)" "$(q meshmanager.smart.roaming_rssi)" "$(q meshmanager.smart.critical_rssi)" "$(q meshmanager.smart.min_dwell)" "$(q meshmanager.smart.cooldown)" "$(q meshmanager.smart.prefer_5g)" "$(q meshmanager.smart.prevent_pingpong)" "$(q meshmanager.smart.bss_transition)" "$(q meshmanager.smart.force_disconnect)" "$(q meshmanager.smart.apply_24)" "$(q meshmanager.smart.apply_5)"
printf '}\n'
