<?php
/**
 * Configuration centrale.
 * - En local (Docker) : les valeurs viennent des variables d'environnement (docker-compose.yml).
 * - En production (Infomaniak) : pas de Docker, donc les valeurs viennent de
 *   config.local.php, placé à la racine du projet (hors du dossier public/) et jamais commité.
 */

$local = __DIR__ . '/../config.local.php';
$fileConfig = is_file($local) ? require $local : [];

if (!function_exists('cfg')) {
function cfg(string $key, array $fileConfig, ?string $default = null): ?string
{
    $env = getenv($key);
    if ($env !== false && $env !== '') {
        return $env;
    }
    return $fileConfig[$key] ?? $default;
}
}

return [
    'APP_ENV'     => cfg('APP_ENV', $fileConfig, 'dev'),
    'DB_HOST'     => cfg('DB_HOST', $fileConfig),
    'DB_NAME'     => cfg('DB_NAME', $fileConfig),
    'DB_USER'     => cfg('DB_USER', $fileConfig),
    'DB_PASSWORD' => cfg('DB_PASSWORD', $fileConfig),
    'SMTP_HOST'   => cfg('SMTP_HOST', $fileConfig),
    'SMTP_PORT'   => cfg('SMTP_PORT', $fileConfig),
];
