<h1>test</h1>
<?php
// Page de test : BDD + envoi de mail
$config = require __DIR__ . '/../src/config.php';
$isProd = $config['APP_ENV'] === 'prod';

$dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', $config['DB_HOST'], $config['DB_NAME']);
try {
    $pdo = new PDO($dsn, $config['DB_USER'], $config['DB_PASSWORD'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $nb = $pdo->query('SELECT COUNT(*) FROM spots')->fetchColumn();
    echo "<p>BDD : connexion OK — $nb lieux</p>";
} catch (PDOException $e) {
    // En production, on n'affiche pas le détail (il peut révéler l'hôte ou l'utilisateur)
    error_log($e->getMessage());
    echo $isProd ? '<p>Erreur BDD</p>' : '<p>Erreur BDD : ' . htmlspecialchars($e->getMessage()) . '</p>';
}

if (!$isProd && isset($_GET['mail'])) {
    $ok = mail('test@example.com', 'Test Mailpit', 'Mail envoyé depuis PHP ' . PHP_VERSION);
    echo $ok ? '<p>Mail envoyé → <a href="http://localhost:8025">Mailpit</a></p>' : '<p>Échec envoi mail</p>';
}
echo '<p>PHP ' . PHP_VERSION . ($isProd ? '' : ' — <a href="?mail=1">Envoyer un mail de test</a>') . '</p>';
