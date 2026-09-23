# site4night

> Projet réalisé dans le cadre du cours _Programmation serveur 2 (ProgServ2)_ à la [HEIG-VD](https://heig-vd.ch/), année académique 2026-2027.

## 1. Équipe

| Membre         | Rôle principal                  | Contact                   |
| -------------- | ------------------------------- | ------------------------- |
| Laurent Ernst  | [ex. base de données, back-end] | laurent.ernst@heig-vd.ch  |
| Samuel Develey | [ex. front-end, i18n]           | samuel.develey@heig-vd.ch |


## 2. Présentation du projet

### 2.1 Contexte

Trouver un endroit pour passer la nuit en tente, en véhicule 4x4 aménagé ou en camping-car est souvent compliqué : les informations sont dispersées (forums, réseaux sociaux, bouche-à-oreille) et rarement à jour. De plus, les règles varient d'un canton et d'une commune à l'autre.

### 2.2 Objectif

L'application permet à une communauté de voyageurs de **référencer, rechercher et évaluer des lieux où passer la nuit**, en précisant pour chaque lieu le ou les types d'hébergement adaptés (tente, 4x4, camping-car) et les équipements disponibles.

### 2.3 Public cible

- Randonneurs et adeptes du bivouac.
- Voyageurs en véhicule 4x4 aménagé (overlanding).
- Voyageurs en camping-car ou van.

### 2.4 Avertissement légal

L'application ne garantit pas la légalité d'un séjour sur un lieu référencé. Chaque fiche affiche un avertissement rappelant que la réglementation (cantonale, communale, zones protégées, propriétés privées) doit être vérifiée par l'utilisateur. Les lieux proposés sont validés par un administrateur avant publication.

## 3. Rôles

|Rôle|Description|
|---|---|
|Visiteur (non connecté)|Consulte et recherche les lieux publiés.|
|Utilisateur|Propose des lieux, rédige des avis, gère ses favoris et son profil.|
|Administrateur|Valide ou refuse les lieux proposés, modère les avis, gère les utilisateurs et les types de lieux.|

## 4. Fonctionnalités principales

### 4.1 Comptes et authentification

- Création de compte (nom d'utilisateur, e-mail, mot de passe).
- Connexion et déconnexion, session maintenue sur toutes les pages.
- Mots de passe stockés de façon sécurisée (`password_hash` / `password_verify`).
- Modification du profil (nom d'utilisateur, e-mail, mot de passe, langue préférée).
- Contrôle d'accès selon le rôle sur chaque page.

### 4.2 Lieux

- Consultation de la liste des lieux publiés.
- Recherche et filtres : type d'hébergement (tente / 4x4 / camping-car), canton ou région, équipements (eau, toilettes, feu autorisé, électricité), gratuit ou payant.
- Fiche détaillée d'un lieu : nom, description, coordonnées GPS, canton, altitude, types d'hébergement, équipements, accès (route goudronnée, piste, sentier), note moyenne et avis.
- Proposition d'un nouveau lieu par un utilisateur (statut « en attente »).
- Modification et suppression de ses propres lieux.

### 4.3 Avis

- Un utilisateur peut laisser un seul avis par lieu (note de 1 à 5 + commentaire + date de visite).
- Modification et suppression de son propre avis.
- Calcul et affichage de la note moyenne d'un lieu.

### 4.4 Favoris

- Ajout et retrait d'un lieu dans ses favoris.
- Page listant ses lieux favoris.

### 4.5 Administration

- Liste des lieux en attente ; validation ou refus avec motif.
- Suppression d'avis inappropriés.
- Gestion des utilisateurs (liste, changement de rôle, désactivation).

### 4.6 E-mails

- E-mail de confirmation à la création du compte.
- E-mail à l'auteur lorsque son lieu est validé ou refusé (avec le motif).

### 4.7 Multilingue (i18n)

- Interface disponible en **français** et en **anglais**.
- Choix de la langue depuis toutes les pages, mémorisé dans la session (et dans le profil pour les utilisateurs connectés).
- Seule l'interface est traduite ; le contenu saisi par les utilisateurs (descriptions, avis) reste dans sa langue d'origine.

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
6. Mes favoris.
7. Rédiger / modifier un avis.
8. _(Administrateur)_ Modération des lieux.
9. _(Administrateur)_ Gestion des utilisateurs.

## 6. Modèle de données (première ébauche)

|Table|Contenu principal|Relations|
|---|---|---|
|`users`|id, username, email, password_hash, role, language, created_at|—|
|`spots`|id, name, description, latitude, longitude, canton, altitude, access_type, is_free, status, refusal_reason, created_at, user_id|N:1 avec `users` (auteur)|
|`accommodation_types`|id, code (tent, 4x4, campervan)|—|
|`spot_accommodation_types`|spot_id, accommodation_type_id|N:N entre `spots` et `accommodation_types`|
|`amenities`|id, code (water, toilets, fire, electricity…)|—|
|`spot_amenities`|spot_id, amenity_id|N:N entre `spots` et `amenities`|
|`reviews`|id, spot_id, user_id, rating, comment, visit_date, created_at|N:1 avec `spots` et `users`, unicité (spot_id, user_id)|
|`favorites`|user_id, spot_id, created_at|N:N entre `users` et `spots`|

Les diagrammes MCD, MLD et MPD seront fournis à la séance 4.

## 7. Contraintes techniques

- PHP orienté objet, sans framework, avec chargement automatique des classes.
- Base de données MySQL/MariaDB, requêtes préparées (PDO).
- Informations de connexion à la base de données dans un fichier de configuration non versionné.
- Protection contre les injections SQL, le XSS et le CSRF ; validation côté client et côté serveur.
- Déploiement sur Infomaniak.
- Workflow Git/GitHub : issues, branches, pull requests, revues.

## 8. Fonctionnalités optionnelles (si le temps le permet)

- Carte interactive des lieux (bibliothèque JavaScript de cartographie, à valider avec le corps enseignant).
- Ajout de photos à un lieu (upload sécurisé).
- Réinitialisation du mot de passe par e-mail.
- Signalement d'un lieu (fermé, interdit, dangereux) par les utilisateurs.
- Export des coordonnées d'un lieu au format GPX.
- Troisième langue (allemand).

## 9. Planification

|Séance|Livrable|
|---|---|
|2|Cahier des charges initial|
|3|Maquette de l'interface utilisateur|
|4|Schéma de la base de données (MCD, MLD, MPD)|
|5|Déploiement sur Infomaniak avec base de données|
|6|Programmation orientée objet|
|7|Sécurité|
|8|Multilingue (i18n)|
|9|Sessions, authentification, autorisation|
|10|Envoi d'e-mails|

## 10. Bilan final

_(À compléter en fin de projet : fonctionnalités réellement implémentées, écarts avec le cahier des charges initial, difficultés rencontrées et solutions apportées, conclusion.)_
