-- =============================================================================
-- site4night – Script de création de la base de données (MariaDB)
-- Projet ProgServ2, HEIG-VD, 2026-2027
--
-- Correspond au MPD : docs/mpd_site4night.drawio.svg
--
-- Utilisation :
--   - En local : phpMyAdmin (http://localhost:9090) → base `my_database` →
--     onglet « SQL » → coller ce script → Exécuter.
--   - En production (Infomaniak) : sélectionner la base dédiée dans
--     phpMyAdmin, puis importer ce fichier.
--
-- Le script peut être relancé : il supprime puis recrée toutes les tables
-- (⚠️ les données existantes sont perdues).
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- Suppression des tables (ordre inverse des dépendances)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS favorites;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS spot_amenities;
DROP TABLE IF EXISTS spot_accommodation_types;
DROP TABLE IF EXISTS spots;
DROP TABLE IF EXISTS amenities;
DROP TABLE IF EXISTS accommodation_types;
DROP TABLE IF EXISTS access_types;
DROP TABLE IF EXISTS cantons;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------------------------------
-- Tables de référence
-- -----------------------------------------------------------------------------
CREATE TABLE cantons (
    code CHAR(2) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (code),
    UNIQUE KEY uq_cantons_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Les libellés affichés sont traduits dans les fichiers de langue (seul le code est stocké).
CREATE TABLE access_types (
    id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_access_types_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE accommodation_types (
    id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_accommodation_types_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE amenities (
    id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_amenities_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Utilisateurs
-- is_active, email_confirmed, confirmation_token : fonctionnalités OPTIONNELLES
-- (désactivation de compte, vérification de l'e-mail par lien).
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') NOT NULL DEFAULT 'user',
    language ENUM('fr', 'en') NOT NULL DEFAULT 'fr',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    email_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    confirmation_token CHAR(64) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_username (username),
    UNIQUE KEY uq_users_email (email),
    UNIQUE KEY uq_users_confirmation_token (confirmation_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Lieux
-- -----------------------------------------------------------------------------
CREATE TABLE spots (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    altitude SMALLINT UNSIGNED NULL,
    is_free BOOLEAN NOT NULL,
    status ENUM('pending', 'published', 'refused') NOT NULL DEFAULT 'pending',
    refusal_reason VARCHAR(500) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    user_id INT UNSIGNED NULL,
    canton_code CHAR(2) NOT NULL,
    access_type_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT ck_spots_latitude CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT ck_spots_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT ck_spots_refusal_reason CHECK (status <> 'refused' OR refusal_reason IS NOT NULL),
    CONSTRAINT fk_spots_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_spots_canton FOREIGN KEY (canton_code) REFERENCES cantons (code)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_spots_access_type FOREIGN KEY (access_type_id) REFERENCES access_types (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Au moins un type d'hébergement par lieu : contrôlé dans l'application.
CREATE TABLE spot_accommodation_types (
    spot_id INT UNSIGNED NOT NULL,
    accommodation_type_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (spot_id, accommodation_type_id),
    CONSTRAINT fk_sat_spot FOREIGN KEY (spot_id) REFERENCES spots (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sat_accommodation_type FOREIGN KEY (accommodation_type_id) REFERENCES accommodation_types (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE spot_amenities (
    spot_id INT UNSIGNED NOT NULL,
    amenity_id TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (spot_id, amenity_id),
    CONSTRAINT fk_sa_spot FOREIGN KEY (spot_id) REFERENCES spots (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sa_amenity FOREIGN KEY (amenity_id) REFERENCES amenities (id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Avis : un seul avis par utilisateur et par lieu
-- -----------------------------------------------------------------------------
CREATE TABLE reviews (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    rating TINYINT UNSIGNED NOT NULL,
    comment TEXT NOT NULL,
    visit_date DATE NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INT UNSIGNED NOT NULL,
    spot_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_reviews_user_spot (user_id, spot_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_spot FOREIGN KEY (spot_id) REFERENCES spots (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- Favoris : fonctionnalité OPTIONNELLE
-- -----------------------------------------------------------------------------
CREATE TABLE favorites (
    user_id INT UNSIGNED NOT NULL,
    spot_id INT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, spot_id),
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users (id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorites_spot FOREIGN KEY (spot_id) REFERENCES spots (id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Données de référence
-- =============================================================================
INSERT INTO cantons (code, name) VALUES
    ('AG', 'Argovie'),
    ('AI', 'Appenzell Rhodes-Intérieures'),
    ('AR', 'Appenzell Rhodes-Extérieures'),
    ('BE', 'Berne'),
    ('BL', 'Bâle-Campagne'),
    ('BS', 'Bâle-Ville'),
    ('FR', 'Fribourg'),
    ('GE', 'Genève'),
    ('GL', 'Glaris'),
    ('GR', 'Grisons'),
    ('JU', 'Jura'),
    ('LU', 'Lucerne'),
    ('NE', 'Neuchâtel'),
    ('NW', 'Nidwald'),
    ('OW', 'Obwald'),
    ('SG', 'Saint-Gall'),
    ('SH', 'Schaffhouse'),
    ('SO', 'Soleure'),
    ('SZ', 'Schwytz'),
    ('TG', 'Thurgovie'),
    ('TI', 'Tessin'),
    ('UR', 'Uri'),
    ('VD', 'Vaud'),
    ('VS', 'Valais'),
    ('ZG', 'Zoug'),
    ('ZH', 'Zurich');

INSERT INTO access_types (id, code) VALUES
    (1, 'paved'),
    (2, 'track'),
    (3, 'trail');

INSERT INTO accommodation_types (id, code) VALUES
    (1, 'tent'),
    (2, '4x4'),
    (3, 'campervan');

INSERT INTO amenities (id, code) VALUES
    (1, 'water'),
    (2, 'toilets'),
    (3, 'fire'),
    (4, 'electricity');

-- =============================================================================
-- Données de test (développement uniquement)
-- ⚠️ En production : changer le mot de passe de l'administrateur dès la mise en
-- ligne, ou supprimer ces comptes de test.
-- Mots de passe (hachés avec password_hash) :
--   admin   → Admin2026!
--   testeur → Test2026!
-- =============================================================================
INSERT INTO users (id, username, email, password_hash, role, language, email_confirmed) VALUES
    (1, 'admin', 'admin@site4night.local', '$2y$10$ls29P5J1GxQiVXvvz/9d7OnohqTgpGBtMzSxhmZWK0FRB3c98Kqgu', 'admin', 'fr', TRUE),
    (2, 'testeur', 'testeur@site4night.local', '$2y$10$wUSN8S5OHJ2H5UgetmglVOz2z/9aEMAPfq6Sp6FCb5lX5SyYtgywm', 'user', 'en', TRUE);

-- Coordonnées et altitudes approximatives (données de test).
INSERT INTO spots (id, name, description, latitude, longitude, altitude, is_free, status, refusal_reason, user_id, canton_code, access_type_id) VALUES
    (1, 'Col du Mollendruz', 'Replat herbeux au sommet du col, accessible toute l''année par route goudronnée. Vue dégagée sur le Jura vaudois.', 46.645000, 6.357000, 1180, TRUE, 'published', NULL, NULL, 'VD', 1),
    (2, 'Lac de Tseuzier', 'Parking au bord du lac de barrage, calme en semaine.', 46.351000, 7.433000, 1777, TRUE, 'published', NULL, 2, 'VS', 1),
    (3, 'Col des Mosses', 'Aire aménagée près du village, payante en saison.', 46.395000, 7.100000, 1445, FALSE, 'published', NULL, NULL, 'VD', 1),
    (4, 'La Berra', 'Clairière au bout d''une piste forestière.', 46.678000, 7.181000, 1300, TRUE, 'pending', NULL, 2, 'FR', 2),
    (5, 'Lac de Moiry', 'Proposition refusée pour tester le motif de refus.', 46.150000, 7.580000, 2250, TRUE, 'refused', 'Bivouac interdit dans cette zone protégée.', 2, 'VS', 1);

INSERT INTO spot_accommodation_types (spot_id, accommodation_type_id) VALUES
    (1, 1), (1, 2), (1, 3),
    (2, 1), (2, 2),
    (3, 3),
    (4, 1), (4, 2),
    (5, 1);

INSERT INTO spot_amenities (spot_id, amenity_id) VALUES
    (1, 1), (1, 2), (1, 3),
    (3, 1), (3, 2), (3, 4);

INSERT INTO reviews (rating, comment, visit_date, user_id, spot_id) VALUES
    (5, 'Super emplacement, plat et calme. Fontaine à 200 m.', '2026-08-12', 2, 1),
    (4, 'Accès facile, belle vue au lever du soleil.', '2026-07-30', 1, 1),
    (4, 'Très calme, prévoir des habits chauds.', '2026-09-02', 1, 2);

INSERT INTO favorites (user_id, spot_id) VALUES
    (2, 1);
