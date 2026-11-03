#!/bin/sh
# Instala el foro la primera vez y lo pone al día en cada despliegue.
# Solo corre en el servicio web (FLARUM_AUTORUN=true), nunca en el scheduler.
set -e
[ "${FLARUM_AUTORUN:-false}" = "true" ] || exit 0
cd /var/www/html

# Vive en el volumen de storage: si el arranque falla a medias, se reintenta en el siguiente.
pending=storage/extensions-pending.txt

state=$(php docker/setup.php)
if [ "$state" = "install" ]; then
    echo "Flarum: primera instalación"
    php flarum install --file=/tmp/install.json
    rm -f /tmp/install.json
    mv /tmp/extensions.txt "$pending"
fi

cp docker/config.php config.php

if [ -f "$pending" ]; then
    while read -r extension; do
        [ -n "$extension" ] || continue
        out=$(php flarum extension:enable "$extension" 2>&1) || echo "$out" | grep -q "already enabled" || { echo "$out"; exit 1; }
        echo "$out"
    done < "$pending"
    rm -f "$pending"
fi

php flarum migrate
php flarum assets:publish
php flarum cache:clear
