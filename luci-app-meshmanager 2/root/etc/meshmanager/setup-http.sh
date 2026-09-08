#!/bin/sh
. /etc/meshmanager/lib.sh
port="$(uci -q get meshmanager.main.controller_port || echo 17891)"
ip="$(mm_lan_ip)"; [ -n "$ip" ] || ip='0.0.0.0'
uci -q delete uhttpd.meshmanager
uci set uhttpd.meshmanager=uhttpd
uci add_list uhttpd.meshmanager.listen_http="$ip:$port"
uci set uhttpd.meshmanager.home='/www/cgi-bin/meshmanager'
uci set uhttpd.meshmanager.cgi_prefix='/'
uci set uhttpd.meshmanager.max_requests='3'
uci set uhttpd.meshmanager.max_connections='30'
uci commit uhttpd
/etc/init.d/uhttpd restart
