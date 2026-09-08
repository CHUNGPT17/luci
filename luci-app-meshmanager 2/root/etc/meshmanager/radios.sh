#!/bin/sh
. /etc/meshmanager/lib.sh
printf '{"radio24":"%s","radio5":"%s"}\n' "$(mm_find_radio 2g)" "$(mm_find_radio 5g)"
