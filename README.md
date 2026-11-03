# Foro Flarum en Coolify

Flarum 2 con MariaDB, empaquetado como Docker Compose para Coolify. El vocabulario está en [CONTEXT.md](CONTEXT.md) y las decisiones en [docs/adr/](docs/adr/).

## Desplegar en Coolify

1. Crea un recurso **Docker Compose** a partir de este repo (GitHub App), con `docker-compose.yaml` como archivo de compose.
2. En **Domains**, asigna tu dominio al servicio `flarum` (`https://foro.tudominio.com`).
3. En **Environment Variables**, rellena `FLARUM_ADMIN_EMAIL` y, si quieres, `FLARUM_ADMIN_USER` y `FLARUM_TITLE`. Las demás variables (`SERVICE_*`) las genera Coolify.
4. Despliega. La primera vez instala el foro y activa todas las extensiones. En los siguientes despliegues solo migra y limpia la caché.
5. La contraseña del admin está en Coolify, en la variable `SERVICE_PASSWORD_FLARUMADMIN`. Cámbiala desde el foro después de entrar por primera vez.

Si la primera instalación falla a medias, vacía el volumen de MariaDB antes de volver a desplegar: el foro da por instalada cualquier base de datos que ya tenga tablas.

## Probar en local

```sh
cp .env.example .env
docker compose up --build    # http://localhost:8080, usuario admin / admin-local-123
docker compose down -v       # lo borra todo, base de datos incluida
```

## Cambios habituales

- **Extensión nueva**: `composer require vendor/paquete` (con el contenedor `serversideup/php:8.4-cli` si no tienes PHP en local), commit y push. En un foro ya instalado, actívala después desde Administración.
- **Parche de PHP o de la imagen base**: `scripts/update-base-image.sh` sube el Dockerfile al último parche de la misma versión de PHP, reconstruye y comprueba en local que el foro arranca. Después, commit y push. También puedes aceptar el PR de Dependabot.
- **Estilos**: edita `extensions/tema/less/forum.less`. Los colores, el logo y el favicon se cambian desde el panel de administración.
- **Correo**: Administración > Correo, cuando Postal esté listo (SMTP, puerto 587, TLS).
