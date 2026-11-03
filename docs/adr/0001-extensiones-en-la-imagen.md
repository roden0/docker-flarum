# Las extensiones se instalan al construir la imagen, no desde el panel

Las extensiones del foro se declaran en `composer.json` y se instalan con `composer require` al construir la imagen del foro. No se usa Extension Manager desde el panel de administración. Así cada despliegue de Coolify produce exactamente el mismo código, Dependabot puede vigilar las versiones y una extensión incompatible rompe el build en lugar de romper producción.

## Consequences

- Añadir, quitar o actualizar una extensión exige un commit y un redespliegue. No se puede hacer desde el admin.
- `vendor/` vive dentro de la imagen y no en un volumen. Revertir esta decisión obligaría a mover `vendor/` a un volumen persistente y a renunciar a builds reproducibles.
