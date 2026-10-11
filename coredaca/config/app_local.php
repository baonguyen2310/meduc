<?php

$debug = false;
if (defined('CLIENT_DEBUG')) {
    $debug = (bool)CLIENT_DEBUG;
}

if (!defined('DB_HOST')) {
    define('DB_HOST', 'localhost');
}

if (!defined('DB_USERNAME')) {
    define('DB_USERNAME', '');
}

if (!defined('DB_PASSWORD')) {
    define('DB_PASSWORD', '');
}

if (!defined('DB_NAME')) {
    define('DB_NAME', '');
}

return [
    'debug' => filter_var(env('APP_DEBUG', false), FILTER_VALIDATE_BOOLEAN),
    'Datasources' => [
        'default' => [
            'host' => DB_HOST,
            'username' => DB_USERNAME,
            'password' => DB_PASSWORD,
            'database' => DB_NAME,
            'url' => env('DATABASE_URL', null),
            'encoding' => 'utf8mb4'
        ]
    ],
    'Security' => [
        'salt' => env('SECURITY_SALT', 'local-development-only-change-me'),
    ],
    'DebugKit' => [
        'forceEnable' => false
    ]
];
