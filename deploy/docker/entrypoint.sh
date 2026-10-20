#!/usr/bin/env bash
# Container start: apply environment settings to all configs, start every component, stream logs.
set -e
cd /ddtank/deploy
python3 -I configure.py /nonexistent.env out
linux/start.sh
trap 'linux/stop.sh; exit 0' TERM INT
tail -F out/run/center.log out/run/fighting.log out/run/road.log out/run/web.log &
wait
