#!/bin/sh
# Actualiza la imagen base (serversideup/php) al último parche de la misma versión
# menor de PHP, reconstruye y comprueba en local que el foro arranca sano.
# Uso: scripts/update-base-image.sh   (desde cualquier carpeta del repo)
set -eu
cd "$(dirname "$0")/.."

current=$(sed -n 's|^FROM serversideup/php:\([0-9.]*\)-fpm-nginx$|\1|p' Dockerfile)
[ -n "$current" ] || { echo "No encuentro 'FROM serversideup/php:X.Y.Z-fpm-nginx' en el Dockerfile" >&2; exit 1; }
minor=${current%.*}

# shortcut: solo mira la primera página (100 etiquetas más recientes); basta mientras se actualice con frecuencia.
latest=$(curl -fsS "https://hub.docker.com/v2/repositories/serversideup/php/tags?page_size=100&ordering=last_updated&name=$minor." |
    python3 -c 'import json, re, sys
minor = sys.argv[1]
tags = [t["name"] for t in json.load(sys.stdin)["results"]]
versions = [t[:-len("-fpm-nginx")] for t in tags if re.fullmatch(re.escape(minor) + r"\.\d+-fpm-nginx", t)]
print(max(versions, key=lambda v: int(v.rsplit(".", 1)[1])) if versions else "")' "$minor")
[ -n "$latest" ] || { echo "Docker Hub no devolvió etiquetas $minor.x-fpm-nginx" >&2; exit 1; }

if [ "$latest" = "$current" ]; then
    echo "Ya estás en la última: serversideup/php:$current-fpm-nginx"
    exit 0
fi

echo "Actualizando $current -> $latest"
sed -i.bak "s|serversideup/php:$current-fpm-nginx|serversideup/php:$latest-fpm-nginx|" Dockerfile && rm Dockerfile.bak

[ -f .env ] || cp .env.example .env
docker compose up -d --build --pull always

echo "Esperando a que el foro esté sano..."
i=0
until [ "$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q flarum)")" = healthy ]; do
    i=$((i + 1))
    [ "$i" -le 60 ] || { echo "El foro no arranca con $latest. Revisa: docker compose logs flarum" >&2; exit 1; }
    sleep 5
done
docker compose exec -T flarum php -v | head -1

echo
echo "Todo bien. Para desplegar:"
echo "  git commit -am 'Imagen base serversideup/php $latest' && git push"
