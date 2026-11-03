# Foro Flarum en Coolify

Despliegue de producción de un foro Flarum, personalizado, que corre como Docker Compose dentro de Coolify.

## Language

**Foro**:
La instancia de Flarum en producción que usan los miembros de la comunidad.
_Avoid_: sitio, web, app

**Imagen del foro**:
La imagen Docker que contiene Flarum, sus extensiones, el tema y la configuración de PHP. Es la única fuente de verdad del código del foro.
_Avoid_: contenedor (un contenedor es una ejecución de la imagen)

**Extensión**:
Paquete Composer que añade funcionalidad al foro. Se instala al construir la imagen, nunca desde el panel de administración.

**Tema**:
Extensión local, versionada en este repo, que define los estilos del foro.
_Avoid_: Custom CSS (es el campo del panel de administración, que no se usa)

**Assets**:
Archivos subidos al foro por usuarios o administradores: imágenes, avatares, logo, favicon. Viven fuera de la imagen y persisten entre despliegues.
_Avoid_: estáticos, media

**Scheduler**:
Proceso que ejecuta cada minuto las tareas programadas del foro.
_Avoid_: cron, worker, cola

**Servicio de correo**:
El servidor SMTP por el que el foro envía sus emails. Será Postal, desplegado como una app aparte en Coolify.
_Avoid_: mailer
