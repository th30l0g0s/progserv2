<?php
$pdo = new PDO(
    'mysql:host=mariadb;port=3306;dbname=my_database;charset=utf8mb4',
    'username',
    'password',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);
echo 'Connexion OK';
