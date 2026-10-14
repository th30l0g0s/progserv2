<?php
// Page de test : BDD + envoi de mail
$dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', getenv('DB_HOST'), getenv('DB_NAME'));
try {
    $pdo = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASSWORD'), [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
    $nb = $pdo->query('SELECT COUNT(*) FROM spots')->fetchColumn();
    echo "<p>BDD : connexion OK — $nb lieux</p>";
} catch (PDOException $e) {
    echo '<p>Erreur BDD : ' . htmlspecialchars($e->getMessage()) . '</p>';
}

if (isset($_GET['mail'])) {
    $ok = mail('test@example.com', 'Test Mailpit', 'Mail envoyé depuis PHP ' . PHP_VERSION);
    echo $ok ? '<p>Mail envoyé → <a href="http://localhost:8025">Mailpit</a></p>' : '<p>Échec envoi mail</p>';
}
echo '<p>PHP ' . PHP_VERSION . ' — <a href="?mail=1">Envoyer un mail de test</a></p>';
