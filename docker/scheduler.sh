#!/bin/sh
# Scheduler: ejecuta `schedule:run` al inicio de cada minuto (Flarum 2 no trae schedule:work).
set -e
cd /var/www/html
cp docker/config.php config.php
trap 'exit 0' TERM INT
while true; do
    php flarum schedule:run || echo "schedule:run falló; se reintenta en el próximo minuto" >&2
    sleep $((60 - $(date +%s) % 60)) &
    wait $!
done
