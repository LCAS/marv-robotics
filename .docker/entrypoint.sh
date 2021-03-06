#!/usr/bin/env bash
#
# Copyright 2016 - 2018  Ternaris.
# SPDX-License-Identifier: AGPL-3.0-only

source /etc/profile.d/marv_env.sh

set -e

if [[ -n "$DEBUG" ]]; then
    set -x
fi

echo "$TIMEZONE" > /etc/timezone
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if [[ -n "$DEVELOP" ]]; then
    find "$DEVELOP" -maxdepth 2 -name setup.py -execdir su -c "$MARV_VENV/bin/pip install -e ." marv \;
fi

( cd "$MARV_SITE" && "$@" ) &
PID="$!"
trap "kill -INT $PID" INT
trap "kill -TERM $PID" TERM
trap "kill -KILL $PID" KILL
echo "Container startup complete."
wait
