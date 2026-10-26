<?php
// Copier en config.local.php sur le serveur (à côté de public/ et src/), puis remplir.
// Ne JAMAIS commiter config.local.php.
return [
    'APP_ENV'     => 'prod',
    'DB_HOST'     => 'XXXX.myd.infomaniak.com', // Manager > Bases de données > infos de configuration
    'DB_NAME'     => 'XXXX_site4night',
    'DB_USER'     => 'XXXX_site4night',
    'DB_PASSWORD' => 'mot-de-passe-fort',
    'SMTP_HOST'   => 'mail.infomaniak.com',
    'SMTP_PORT'   => '465',
];
