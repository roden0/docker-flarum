#!/bin/sh
# Instala el foro la primera vez y lo pone al día en cada despliegue.
# Solo corre en el servicio web (FLARUM_AUTORUN=true), nunca en el scheduler.
set -e
[ "${FLARUM_AUTORUN:-false}" = "true" ] || exit 0
cd /var/www/html

state=$(php docker/setup.php)
if [ "$state" = "install" ]; then
    echo "Flarum: primera instalación"
    php flarum install --file=/tmp/install.json
    rm -f /tmp/install.json
fi

cp docker/config.php config.php

if [ "$state" = "install" ]; then
    while read -r extension; do
        php flarum extension:enable "$extension"
    done < /tmp/extensions.txt
    rm -f /tmp/extensions.txt
fi

php flarum migrate
php flarum assets:publish
php flarum cache:clear
