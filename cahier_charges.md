# site4night - Cahier des charges

> Projet réalisé dans le cadre du cours _Programmation serveur 2 (ProgServ2)_ à
> la [HEIG-VD](https://heig-vd.ch/), année académique 2026-2027.

## 1. Équipe

| Membre         | Rôle principal                                                                            | Contact                   |
| -------------- | ----------------------------------------------------------------------------------------- | ------------------------- |
| Laurent Ernst  | Développement complet (back-end, front-end, BDD, déploiement)                             | laurent.ernst@heig-vd.ch  |
| Samuel Develey | Infrastructure Docker, schémas BDD, wireframes — a quitté la formation en cours de projet | samuel.develey@heig-vd.ch |

> [!IMPORTANT]
>
> Suite au départ de Samuel Develey, le projet est réalisé par une seule
> personne, alors que le règlement du projet prévoit des groupes de deux à trois
> personnes. Le corps enseignant est informé et a validé ce fonctionnement. La
> portée a été réduite en conséquence (favoris et gestion des utilisateurs
> passés en fonctionnalités optionnelles).

## 2. Présentation du projet

### 2.1 Contexte

Trouver un endroit pour passer la nuit en tente, en véhicule 4x4 aménagé ou en
camping-car est souvent compliqué : les informations sont dispersées (forums,
réseaux sociaux, bouche-à-oreille) et rarement à jour. De plus, les règles
varient d'un canton et d'une commune à l'autre.

### 2.2 Objectif

L'application permet à une communauté de voyageurs de **référencer, rechercher
et évaluer des lieux où passer la nuit**, en précisant pour chaque lieu le ou
les types d'hébergement adaptés (tente, 4x4, camping-car) et les équipements
disponibles.

### 2.3 Public cible

- Randonneurs et adeptes du bivouac.
- Voyageurs en véhicule 4x4 aménagé (overlanding).
- Voyageurs en camping-car ou van.

### 2.4 Avertissement légal

L'application ne garantit pas la légalité d'un séjour sur un lieu référencé.
Chaque fiche affiche un avertissement rappelant que la réglementation
(cantonale, communale, zones protégées, propriétés privées) doit être vérifiée
par l'utilisateur. Les lieux proposés sont validés par un administrateur avant
publication.

## 3. Rôles

| Rôle                    | Description                                                                                        |
| ----------------------- | -------------------------------------------------------------------------------------------------- |
| Visiteur (non connecté) | Consulte et recherche les lieux publiés.                                                           |
| Utilisateur             | Propose des lieux, rédige des avis, gère son profil.                                               |
| Administrateur          | Valide ou refuse les lieux proposés, modère les avis.                                              |

## 4. Fonctionnalités principales

### 4.1 Comptes et authentification

- Création de compte (nom d'utilisateur, e-mail, mot de passe).
- Connexion et déconnexion, session maintenue sur toutes les pages.
- Mots de passe stockés de façon sécurisée (`password_hash` /
  `password_verify`).
- Modification du profil (nom d'utilisateur, e-mail, mot de passe, langue
  préférée).
- Contrôle d'accès selon le rôle sur chaque page.

### 4.2 Lieux

- Consultation de la liste des lieux publiés.
- Recherche et filtres : type d'hébergement (tente / 4x4 / camping-car), canton,
  équipements (eau, toilettes, feu autorisé, électricité), gratuit ou
  payant.
- Fiche détaillée d'un lieu : nom, description, coordonnées GPS, canton,
  altitude, types d'hébergement, équipements, accès (route goudronnée, piste,
  sentier), note moyenne et avis.
- Proposition d'un nouveau lieu par un utilisateur (statut « en attente »).
- Modification et suppression de ses propres lieux.

### 4.3 Avis

- Un utilisateur peut laisser un seul avis par lieu (note de 1 à 5 +
  commentaire + date de visite).
- Modification et suppression de son propre avis.
- Calcul et affichage de la note moyenne d'un lieu.

### 4.4 Administration

- Liste des lieux en attente ; validation ou refus avec motif.
- Suppression d'avis inappropriés.
- Le premier compte administrateur est créé par le script SQL d'initialisation.

### 4.5 E-mails

- E-mail de bienvenue à la création du compte (sans lien de validation).
- E-mail à l'auteur lorsque son lieu est validé ou refusé (avec le motif).
- Envoi avec la bibliothèque PHPMailer ; serveur SMTP Mailpit en développement,
  SMTP Infomaniak en production.

### 4.6 Multilingue (i18n)

- Interface disponible en **français** et en **anglais**.
- Choix de la langue depuis toutes les pages, mémorisé dans un cookie
  `language` (et dans le profil pour les utilisateurs connectés).
- Les libellés des types d'hébergement et des équipements sont traduits via les
  fichiers de langue (seul leur code est stocké en base).
- Seule l'interface est traduite ; le contenu saisi par les utilisateurs
  (descriptions, avis) reste dans sa langue d'origine.

## 5. Pages prévues

### Pages publiques (sans connexion)

1. Accueil – présentation du concept et accès rapide à la recherche.
2. Liste et recherche des lieux.
3. Détail d'un lieu.
4. Inscription.
5. Connexion.

### Pages privées (après connexion)

1. Tableau de bord / profil.
2. Modification du profil.
3. Proposer un lieu.
4. Mes lieux (avec statut : en attente, publié, refusé).
5. Modifier un lieu.
6. Rédiger / modifier un avis.
7. _(Administrateur)_ Modération des lieux.

## 6. Modèle de données

Diagrammes (draw.io, modifiables) : [MCD](docs/mcd_site4night.drawio.svg) ·
[MLD](docs/mld_site4night.drawio.svg) · [MPD](docs/mpd_site4night.drawio.svg).
Script de création : [`src/db/script.sql`](src/db/script.sql).

| Table                      | Contenu principal                                                                                                                                                  | Relations                                                  |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| `users`                    | id, username, email, password_hash, role, language, created_at, updated_at · _optionnel :_ is_active, email_confirmed, confirmation_token                           | —                                                          |
| `spots`                    | id, name, description, latitude, longitude, altitude, is_free, status, refusal_reason, created_at, updated_at, user_id, canton_code, access_type_id                  | N:1 avec `users` (auteur), `cantons`, `access_types`       |
| `cantons`                  | code (VD, GE…), name — liste fixe des 26 cantons                                                                                                                   | —                                                          |
| `access_types`             | id, code (paved, track, trail)                                                                                                                                     | —                                                          |
| `accommodation_types`      | id, code (tent, 4x4, campervan)                                                                                                                                    | —                                                          |
| `spot_accommodation_types` | spot_id, accommodation_type_id                                                                                                                                     | N:N entre `spots` et `accommodation_types` (au moins 1)    |
| `amenities`                | id, code (water, toilets, fire, electricity)                                                                                                                       | —                                                          |
| `spot_amenities`           | spot_id, amenity_id                                                                                                                                                | N:N entre `spots` et `amenities`                           |
| `reviews`                  | id, rating, comment, visit_date, created_at, user_id, spot_id                                                                                                      | N:1 avec `users` et `spots`, unicité (user_id, spot_id)    |
| `favorites`                | user_id, spot_id, created_at                                                                                                                                       | N:N entre `users` et `spots` — _optionnel_                 |

Valeurs énumérées :

- `users.role` : `user`, `admin` · `users.language` : `fr`, `en`.
- `spots.status` : `pending`, `published`, `refused`.

Règles d'intégrité :

- Note d'un avis entre 1 et 5 ; motif de refus obligatoire si le lieu est
  refusé ; latitude et longitude dans les bornes GPS (contraintes `CHECK`).
- Suppression d'un lieu ou d'un utilisateur : suppression en cascade de ses
  avis et favoris. Suppression d'un utilisateur : ses lieux sont conservés,
  sans auteur (`ON DELETE SET NULL`).
- Un canton, un type d'accès, d'hébergement ou d'équipement utilisé ne peut pas
  être supprimé (`ON DELETE RESTRICT`).
- La note moyenne d'un lieu est calculée, pas stockée.
- Les éléments optionnels (favoris, désactivation de compte, vérification de
  l'e-mail) sont créés dans la base mais utilisés seulement si la
  fonctionnalité est réalisée.

## 7. Contraintes techniques

- PHP orienté objet, sans framework, avec chargement automatique des classes.
- Base de données MySQL/MariaDB, requêtes préparées (PDO).
- Informations de connexion à la base de données dans un fichier de
  configuration non versionné.
- Protection contre les injections SQL, le XSS et le CSRF ; validation côté
  client et côté serveur.
- Environnement de développement : modèle Docker Compose du cours (Apache +
  PHP 8.5, MariaDB 12, phpMyAdmin, Mailpit).
- Déploiement sur Infomaniak avec une base de données MySQL/MariaDB dédiée.
- Workflow Git/GitHub : issues, branches, pull requests, revues.

## 8. Correspondance avec les critères du produit final

| Critère de la grille                      | Couverture prévue                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------- |
| ≥ 2 pages publiques                       | 5 pages publiques (section 5)                                              |
| ≥ 5 pages privées                         | 7 pages privées (section 5)                                                |
| ≥ 2 langues                               | Français, anglais (4.6)                                                    |
| Page d'accueil explicite                  | Accueil avec présentation et accès à la recherche                          |
| Création de compte et connexion           | 4.1                                                                        |
| Mise à jour du profil et déconnexion      | 4.1                                                                        |
| Session maintenue sur toutes les pages    | 4.1                                                                        |
| ≥ 2 rôles                                 | Utilisateur, administrateur (section 3)                                    |
| ≥ 2 domaines liés                         | Utilisateurs, lieux, avis, types, équipements (section 6)                  |
| Mots de passe sécurisés                   | `password_hash` / `password_verify`                                        |
| POO et chargement automatique des classes | Section 7                                                                  |
| Configuration BDD dans un fichier         | Fichier de configuration non versionné (section 7)                         |
| Envoi d'e-mails                           | 4.5                                                                        |

## 9. Fonctionnalités optionnelles (si le temps le permet)

Par ordre de priorité :

- Favoris : ajout et retrait d'un lieu, page « Mes favoris » (table
  `favorites`).
- Gestion des utilisateurs par l'administrateur : liste, changement de rôle,
  désactivation (colonne `users.is_active`).
- Carte interactive des lieux (bibliothèque JavaScript de cartographie, à
  valider avec le corps enseignant).
- Ajout de photos à un lieu (upload sécurisé).
- Réinitialisation du mot de passe par e-mail.
- Vérification de l'adresse e-mail par lien à l'inscription.
- Signalement d'un lieu (fermé, interdit, dangereux) par les utilisateurs.
- Export des coordonnées d'un lieu au format GPX.
- Troisième langue (allemand).

## 10. Planification

| Séance | Livrable                                        |
| ------ | ----------------------------------------------- |
| 2      | Cahier des charges initial                      |
| 3      | Maquette de l'interface utilisateur             |
| 4      | Schéma de la base de données (MCD, MLD, MPD)    |
| 5      | Déploiement sur Infomaniak avec base de données |
| 6      | Programmation orientée objet                    |
| 7      | Sécurité                                        |
| 8      | Multilingue (i18n)                              |
| 9      | Sessions, authentification, autorisation        |
| 10     | Envoi d'e-mails                                 |

## 11. Utilisation d'outils d'intelligence artificielle

Conformément aux règles du projet, toute aide externe est déclarée ici
(**quand**, **comment**, **pourquoi**) et dans le code concerné.

| Date       | Outil         | Élément concerné     | Utilisation et justification                                                                                                                                                                                                         |
| ---------- | ------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 19.11.2026 | Claude (Anthropic) | `cahier_charges.md` | Relecture du cahier des charges par rapport aux critères officiels du projet, ajout de la correspondance avec la grille, précision du modèle de données et des e-mails. Contenu relu, compris et validé par l'auteur. |
| 20.11.2026 | Claude (Anthropic) | Diagrammes, `src/db/script.sql`, § 6 | Ajout de `updated_at` et du marquage « optionnel » dans les diagrammes réalisés par l'auteur, correction de deux notes, rédaction et test du script SQL à partir du MPD, mise à jour du § 6. |

## 12. Bilan final

_(À compléter en fin de projet : fonctionnalités réellement implémentées, écarts
avec le cahier des charges initial, difficultés rencontrées et solutions
apportées, conclusion.)_
