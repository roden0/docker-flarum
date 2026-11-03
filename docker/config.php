<?php

// config.php del foro: todo sale de las variables de entorno del contenedor (Coolify).
return [
    'debug' => getenv('FLARUM_DEBUG') === 'true',
    'offline' => false,
    'database' => [
        'driver' => 'mariadb',
        'host' => getenv('DB_HOST'),
        'port' => (int) (getenv('DB_PORT') ?: 3306),
        'database' => getenv('DB_DATABASE'),
        'username' => getenv('DB_USERNAME'),
        'password' => getenv('DB_PASSWORD'),
        'charset' => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix' => '',
        'strict' => false,
    ],
    'url' => getenv('FLARUM_URL'),
    'paths' => ['api' => 'api', 'admin' => 'admin'],
    'queue' => ['driver' => 'sync'],
    'fontawesome' => ['source' => 'local'],
];
