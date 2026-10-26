# Déploiement site4night sur Infomaniak

Cible : `https://progserv2.laurenternst.ch`
Durée totale estimée : **45 à 60 min** la première fois, **2 min** ensuite (étape 7 seule).

## Ce qui change entre Docker (local) et Infomaniak (production)

| Service Docker | Équivalent Infomaniak |
|---|---|
| `web` (Apache + PHP 8.5) | Hébergement web, PHP réglé dans le Manager |
| `db` (MariaDB 11.4) | Base MariaDB créée dans le Manager (hôte `XXXX.myd.infomaniak.com`) |
| `phpmyadmin` | phpMyAdmin fourni par Infomaniak |
| `mailpit` | Pas d'équivalent : en prod, envoi réel via SMTP Infomaniak (plus tard, avec PHPMailer) |
| Variables d'environnement | Fichier `config.local.php` sur le serveur, hors de `public/` |

## Étapes

### 1. Ajouter le sous-domaine comme site — 10 min
1. Manager Infomaniak → Hébergement web → cliquer sur l'hébergement → **Ajouter**.
2. Choisir « espace vide », puis l'option **sous-domaine** de `laurenternst.ch` → saisir `progserv2`.
3. Options avancées → **Définir l'emplacement manuellement** → dossier : `/sites/progserv2/public`.
   - Raison : seul `public/` doit être accessible depuis le web. `src/` et `config.local.php` restent invisibles.
4. Si le DNS de `laurenternst.ch` n'est pas géré chez Infomaniak : créer l'entrée chez le registrar.

### 2. Régler PHP — 2 min
1. Fiche du site → « Plus d'informations » → **Modifier** → PHP **8.5** (comme le Dockerfile).
2. ⚠️ Infomaniak indique qu'on ne peut pas redescendre de version ensuite.
3. Si 8.5 n'est pas proposé sur ta formule : prendre 8.4 (le code actuel n'utilise rien de spécifique à 8.5).

### 3. Activer le certificat SSL — 5 min (+ délai de propagation)
1. Fiche du site → SSL → certificat Let's Encrypt gratuit.
2. Le `.htaccess` force déjà la redirection HTTP → HTTPS.

### 4. Créer la base de données — 5 min
1. Manager → Hébergement → **Bases de données** → Ajouter une base de données (ex. `site4night`).
2. Créer un utilisateur avec mot de passe fort, droits lecture + écriture sur cette base.
3. Noter les 4 valeurs exactes affichées : **hôte**, **nom de la base** (avec préfixe), **utilisateur** (avec préfixe), **mot de passe**.

### 5. Importer le schéma et les données — 5 min
1. Ouvrir phpMyAdmin depuis le Manager → sélectionner la base.
2. Onglet **Importer** → fichier `docker/db/init/02-site4night.sql`.
3. Vérifier : 10 tables, dont `spots` avec des lignes.

> ⚠️ **Sécurité** : ce fichier crée un compte `admin` dont le mot de passe (`Password123!`) est écrit en clair dans un commentaire du dépôt **public** GitHub. Dès que la connexion sera codée, n'importe qui pourra se connecter en admin sur le site en ligne. Avant la mise en ligne publique : changer ce mot de passe en prod, ou importer une version sans les utilisateurs de test.

### 6. Activer SSH et préparer la configuration — 10 min
1. Manager → Hébergement → **FTP / SSH** → créer un compte, activer SSH. Noter utilisateur et hôte.
2. Sur le Mac, tester : `ssh XXXX_user@XXXX.ftp.infomaniak.com`
3. Sur le serveur, créer `sites/progserv2/config.local.php` à partir de `config.local.example.php` et remplir les 4 valeurs de l'étape 4 (`APP_ENV` = `prod`).
   - Ce fichier n'est jamais envoyé par le script ni commité (`.gitignore`).

### 7. Envoyer le code — 2 min (à chaque mise à jour)
1. Ouvrir `deploy/deploy.sh` et remplacer `SSH_USER` et `SSH_HOST` (une seule fois).
2. Simulation : `./deploy/deploy.sh --dry` → vérifier la liste des fichiers.
3. Envoi réel : `./deploy/deploy.sh`

Le script n'envoie que `public/` et `src/` (+ `config.local.example.php`). Docker, maquettes, BDD et Markdown restent sur le Mac.

> Sans SSH : glisser `public/`, `src/` dans `sites/progserv2/` avec un client SFTP (Cyberduck, Transmit) ou le FTP Manager.

### 8. Vérifier — 2 min
- `https://progserv2.laurenternst.ch` affiche « BDD : connexion OK — N lieux ».
- `https://progserv2.laurenternst.ch/src/config.php` doit renvoyer une erreur 404 (preuve que la racine web est bien `public/`).
- En cas de « Erreur BDD » : revoir les 4 valeurs de `config.local.php` (hôte et préfixes surtout).

## Fichiers modifiés dans le dépôt

- `src/config.php` (nouveau) : lit les variables d'environnement (Docker) puis, à défaut, `config.local.php` (Infomaniak).
- `config.local.example.php` (nouveau) : modèle à copier sur le serveur.
- `public/index.php` : utilise `src/config.php` ; en prod, masque le détail des erreurs BDD et le lien de test mail.
- `public/.htaccess` (nouveau) : HTTPS forcé (sauf `localhost`), erreurs masquées, fichiers cachés bloqués.
- `deploy/deploy.sh` (nouveau) : envoi par rsync/SSH, avec mode simulation.
- `.gitignore` : ajoute `config.local.php` et `.DS_Store`.

Le fonctionnement local avec `docker compose up` reste identique.

## Plus tard (pas bloquant pour ce déploiement)
- E-mails (inscription, validation de lieux) : PHPMailer + SMTP `mail.infomaniak.com`, avec une adresse e-mail réelle du domaine.
- `docker/php/php.ini` a `display_errors = On` : correct en local. En prod, ce fichier n'est pas utilisé ; vérifier dans le Manager (réglages PHP du site) que `display_errors` est désactivé, la ligne du `.htaccess` ne s'appliquant que si PHP tourne en module Apache.
