<?php

// Decide si el foro ya está instalado. Imprime "installed", o bien escribe
// /tmp/install.json para `php flarum install`, /tmp/extensions.txt con las
// extensiones a activar después, e imprime "install".
// Sale con error si la base de datos no responde, para no instalar nunca a ciegas.

function env(string $key): string
{
    $value = getenv($key);
    if ($value === false || $value === '') {
        fwrite(STDERR, "Falta la variable de entorno $key\n");
        exit(1);
    }
    return $value;
}

$db = [
    'host' => env('DB_HOST'),
    'port' => (int) (getenv('DB_PORT') ?: 3306),
    'database' => env('DB_DATABASE'),
    'username' => env('DB_USERNAME'),
    'password' => env('DB_PASSWORD'),
];

for ($attempt = 1; ; $attempt++) {
    try {
        $pdo = new PDO("mysql:host={$db['host']};port={$db['port']};dbname={$db['database']}", $db['username'], $db['password']);
        break;
    } catch (PDOException $e) {
        if ($attempt >= 30) {
            fwrite(STDERR, "La base de datos no responde: {$e->getMessage()}\n");
            exit(1);
        }
        sleep(2);
    }
}

if ($pdo->query("SHOW TABLES LIKE 'migrations'")->fetchColumn() !== false) {
    echo 'installed';
    exit(0);
}

// Todas las extensiones de la imagen (mismo id que Extension::nameToId). No se pasan al
// instalador: algunas migraciones de FoF necesitan Flarum arrancado y fallan en él.
$installed = json_decode(file_get_contents(__DIR__.'/../vendor/composer/installed.json'), true);
$extensions = [];
foreach ($installed['packages'] ?? $installed as $package) {
    if (($package['type'] ?? '') === 'flarum-extension') {
        [$vendor, $name] = explode('/', $package['name'], 2);
        $extensions[] = $vendor.'-'.str_replace(['flarum-ext-', 'flarum-'], '', $name);
    }
}

file_put_contents('/tmp/install.json', json_encode([
    'debug' => false,
    'baseUrl' => env('FLARUM_URL'),
    'databaseConfiguration' => ['driver' => 'mariadb'] + $db,
    'adminUser' => [
        'username' => env('FLARUM_ADMIN_USER'),
        'email' => env('FLARUM_ADMIN_EMAIL'),
        'password' => env('FLARUM_ADMIN_PASSWORD'),
    ],
    'settings' => [
        'forum_title' => getenv('FLARUM_TITLE') ?: 'Foro',
        'default_locale' => 'es',
    ],
]));
// Las que el instalador ya activa por defecto darían error al activarlas otra vez.
require __DIR__.'/../vendor/autoload.php';
$extensions = array_diff($extensions, Flarum\Install\Steps\EnableBundledExtensions::DEFAULT_ENABLED_EXTENSIONS);
file_put_contents('/tmp/extensions.txt', implode("\n", $extensions)."\n");
echo 'install';
