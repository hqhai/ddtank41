#!/usr/bin/env bash
# Start the whole game on Linux (after deploy/setup.sh). Each component runs in its own tmux session:
#   ddt-center, ddt-fighting, ddt-road   game servers (mono)
#   ddt-web                              ASP.NET via fastcgi-mono-server4 (+ nginx, daemonized)
#   ddt-ws                               websockify bridge for the browser client (Ruffle)
# Attach to a server console with:  tmux attach -t ddt-road     (detach: Ctrl-b d)
# Stop everything with:             deploy/linux/stop.sh
#
# Requires: mono-complete, mono-fastcgi-server4, nginx, websockify, tmux, and a running SQL Server
# with the databases restored (see deploy/linux/db.sh).
set -euo pipefail
D="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$D/out"
RUN="$OUT/run"
mkdir -p "$RUN/tmp"
set -a; . "$D/server.env"; set +a
WEB_PORT="${WEB_PORT:-80}"; GAME_PORT="${GAME_PORT:-9500}"; WS_PORT="${WS_PORT:-9501}"; FCGI_PORT="${FCGI_PORT:-9000}"

start() { # name dir command
  tmux has-session -t "$1" 2>/dev/null && { echo "$1 already running"; return; }
  tmux new-session -d -s "$1" -c "$2" "$3; echo '[exited] press enter'; read"
  echo "started $1"
}
wait_log() { # file pattern timeout
  for _ in $(seq 1 "$3"); do grep -q "$2" "$1" 2>/dev/null && return 0; sleep 1; done
  echo "!! timeout waiting for '$2' in $1"; return 1
}

for svc in Center Fighting Road; do rm -rf "$OUT/server/$svc.Service/logs"; done

start ddt-center "$OUT/server/Center.Service" "mono Center.Service.exe 2>&1 | tee $RUN/center.log"
wait_log "$RUN/center.log" "is now open for connections" 120
start ddt-fighting "$OUT/server/Fighting.Service" "mono Fighting.Service.exe 2>&1 | tee $RUN/fighting.log"
wait_log "$RUN/fighting.log" "is now open for connections" 180
start ddt-road "$OUT/server/Road.Service" "mono Road.Service.exe 2>&1 | tee $RUN/road.log"
wait_log "$RUN/road.log" "Server started" 300

start ddt-web "$OUT/web" "fastcgi-mono-server4 /applications=/:$OUT/web/Tank.Flash,/request:$OUT/web/Tank.Request /socket=tcp:127.0.0.1:$FCGI_PORT 2>&1 | tee $RUN/web.log"
python3 -I "$D/linux/casemap.py" "$OUT" "$RUN/casemap.txt"
FASTCGI="fastcgi_param PATH_INFO \"\"; fastcgi_param SCRIPT_FILENAME \$request_filename; fastcgi_pass 127.0.0.1:$FCGI_PORT;"
sed -e "s#__RUN__#$RUN#g; s#__OUT__#$OUT#g; s#__WEB_PORT__#$WEB_PORT#g" -e "s#__FASTCGI__#$FASTCGI#g" \
  "$D/linux/nginx.conf.template" > "$RUN/nginx.conf"
nginx -c "$RUN/nginx.conf" -t -q && nginx -c "$RUN/nginx.conf"
echo "started nginx on :$WEB_PORT"

start ddt-ws "$RUN" "websockify $WS_PORT 127.0.0.1:$GAME_PORT 2>&1 | tee $RUN/websockify.log"

echo
echo "Game ready:  http://${PUBLIC_HOST}$( [ "$WEB_PORT" = 80 ] || echo ":$WEB_PORT" )/"
