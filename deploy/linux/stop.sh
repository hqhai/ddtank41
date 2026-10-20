#!/usr/bin/env bash
# Stop everything started by deploy/linux/start.sh
D="$(cd "$(dirname "$0")/.." && pwd)"
RUN="$D/out/run"
for s in ddt-ws ddt-web ddt-road ddt-fighting ddt-center; do
  if tmux has-session -t "$s" 2>/dev/null; then
    # game servers save to the database on "exit"
    case "$s" in ddt-road|ddt-fighting|ddt-center) tmux send-keys -t "$s" "exit" Enter; sleep 5;; esac
    tmux kill-session -t "$s" 2>/dev/null && echo "stopped $s"
  fi
done
[ -f "$RUN/nginx.pid" ] && nginx -c "$RUN/nginx.conf" -s quit 2>/dev/null && echo "stopped nginx"
true
