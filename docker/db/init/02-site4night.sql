-- ================================================================
-- site4night, MPD (MariaDB) + données de test
-- ===============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS spot_amenities, spot_accommodation_types, favorites, reviews,
                     spots, amenities, accommodation_types, access_types, cantons, users;

SET FOREIGN_KEY_CHECKS = 1;

-- Tables


CREATE TABLE users (
    id                 INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    username           VARCHAR(50)      NOT NULL,
    email              VARCHAR(255)     NOT NULL,
    password_hash      VARCHAR(255)     NOT NULL,
    role               ENUM('user','admin') NOT NULL DEFAULT 'user',
    language           ENUM('fr','en')  NOT NULL DEFAULT 'fr',
    is_active          BOOLEAN          NOT NULL DEFAULT TRUE,
    email_confirmed    BOOLEAN          NOT NULL DEFAULT FALSE,
    confirmation_token CHAR(64)         NULL,
    created_at         DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_users PRIMARY KEY (id),
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT uq_users_confirmation_token UNIQUE (confirmation_token)
);

CREATE TABLE cantons (
    code CHAR(2)     NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_cantons PRIMARY KEY (code),
    CONSTRAINT uq_cantons_name UNIQUE (name)
);

CREATE TABLE access_types (
    id   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30)      NOT NULL,
    CONSTRAINT pk_access_types PRIMARY KEY (id),
    CONSTRAINT uq_access_types_code UNIQUE (code)
);

CREATE TABLE accommodation_types (
    id   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30)      NOT NULL,
    CONSTRAINT pk_accommodation_types PRIMARY KEY (id),
    CONSTRAINT uq_accommodation_types_code UNIQUE (code)
);

CREATE TABLE amenities (
    id   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30)      NOT NULL,
    CONSTRAINT pk_amenities PRIMARY KEY (id),
    CONSTRAINT uq_amenities_code UNIQUE (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE spots (
    id             INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    name           VARCHAR(100)      NOT NULL,
    description    TEXT              NOT NULL,
    latitude       DECIMAL(9,6)      NOT NULL,
    longitude      DECIMAL(9,6)      NOT NULL,
    altitude       SMALLINT UNSIGNED NULL,
    is_free        BOOLEAN           NOT NULL DEFAULT TRUE,
    status         ENUM('pending','published','refused') NOT NULL DEFAULT 'pending',
    refusal_reason VARCHAR(500)      NULL,
    created_at     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id        INT UNSIGNED      NULL,
    canton_code    CHAR(2)           NOT NULL,
    access_type_id TINYINT UNSIGNED  NOT NULL,
    CONSTRAINT pk_spots PRIMARY KEY (id),
    CONSTRAINT ck_spots_latitude  CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_spots_longitude CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT ck_spots_refusal   CHECK (status <> 'refused' OR refusal_reason IS NOT NULL),
    CONSTRAINT fk_spots_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_spots_canton FOREIGN KEY (canton_code)
        REFERENCES cantons (code) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_spots_access_type FOREIGN KEY (access_type_id)
        REFERENCES access_types (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_spots_status (status)
);

CREATE TABLE reviews (
    id         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    rating     TINYINT UNSIGNED NOT NULL,
    comment    TEXT             NOT NULL,
    visit_date DATE             NOT NULL,
    created_at DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id    INT UNSIGNED     NOT NULL,
    spot_id    INT UNSIGNED     NOT NULL,
    CONSTRAINT pk_reviews PRIMARY KEY (id),
    CONSTRAINT uq_reviews_user_spot UNIQUE (user_id, spot_id),
    CONSTRAINT ck_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_spot FOREIGN KEY (spot_id)
        REFERENCES spots (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE favorites (
    user_id    INT UNSIGNED NOT NULL,
    spot_id    INT UNSIGNED NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_favorites PRIMARY KEY (user_id, spot_id),
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_favorites_spot FOREIGN KEY (spot_id)
        REFERENCES spots (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE spot_accommodation_types (
    spot_id               INT UNSIGNED     NOT NULL,
    accommodation_type_id TINYINT UNSIGNED NOT NULL,
    CONSTRAINT pk_spot_accommodation_types PRIMARY KEY (spot_id, accommodation_type_id),
    CONSTRAINT fk_sat_spot FOREIGN KEY (spot_id)
        REFERENCES spots (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sat_accommodation_type FOREIGN KEY (accommodation_type_id)
        REFERENCES accommodation_types (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE spot_amenities (
    spot_id    INT UNSIGNED     NOT NULL,
    amenity_id TINYINT UNSIGNED NOT NULL,
    CONSTRAINT pk_spot_amenities PRIMARY KEY (spot_id, amenity_id),
    CONSTRAINT fk_sa_spot FOREIGN KEY (spot_id)
        REFERENCES spots (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sa_amenity FOREIGN KEY (amenity_id)
        REFERENCES amenities (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Données de référence

INSERT INTO cantons (code, name) VALUES
('AG','Argovie'), ('AI','Appenzell Rhodes-Intérieures'), ('AR','Appenzell Rhodes-Extérieures'),
('BE','Berne'), ('BL','Bâle-Campagne'), ('BS','Bâle-Ville'), ('FR','Fribourg'), ('GE','Genève'),
('GL','Glaris'), ('GR','Grisons'), ('JU','Jura'), ('LU','Lucerne'), ('NE','Neuchâtel'),
('NW','Nidwald'), ('OW','Obwald'), ('SG','Saint-Gall'), ('SH','Schaffhouse'), ('SO','Soleure'),
('SZ','Schwytz'), ('TG','Thurgovie'), ('TI','Tessin'), ('UR','Uri'), ('VD','Vaud'),
('VS','Valais'), ('ZG','Zoug'), ('ZH','Zurich');

INSERT INTO access_types (id, code) VALUES
(1,'paved'), (2,'track'), (3,'trail');

INSERT INTO accommodation_types (id, code) VALUES
(1,'tent'), (2,'4x4'), (3,'campervan');

INSERT INTO amenities (id, code) VALUES
(1,'water'), (2,'toilets'), (3,'fire'), (4,'electricity');

-- Données de test

-- Hash de "Password123!" (password_hash, PASSWORD_DEFAULT)
SET @pwd = '$2y$10$qUGC1AW4htY0fTvVr9iMWuQjSHMBQhx3q07v7xnnAMI.zpt6FQHom';

INSERT INTO users (id, username, email, password_hash, role, language, is_active, email_confirmed, confirmation_token, created_at) VALUES
(1, 'admin',         'admin@site4night.test', @pwd, 'admin', 'fr', TRUE,  TRUE,  NULL, '2026-05-01 09:00:00'),
(2, 'lucie_bivouac', 'lucie@site4night.test', @pwd, 'user',  'fr', TRUE,  TRUE,  NULL, '2026-06-03 18:24:00'),
(3, 'marco4x4',      'marco@site4night.test', @pwd, 'user',  'fr', TRUE,  TRUE,  NULL, '2026-06-05 20:11:00'),
(4, 'sarah_van',     'sarah@site4night.test', @pwd, 'user',  'en', TRUE,  TRUE,  NULL, '2026-06-10 07:45:00'),
(5, 'tom_rando',     'tom@site4night.test',   @pwd, 'user',  'fr', TRUE,  TRUE,  NULL, '2026-09-20 21:30:00'),
-- compte pas encore confirmé (jeton en attente)
(6, 'nina_new',      'nina@site4night.test',  @pwd, 'user',  'en', TRUE,  FALSE,
    'a3f9c2e8b7d14f6a9e0c5b8d2f7a1e4c6b9d0f3a8e2c7b5d1f4a9c6e3b8d2f70', '2026-10-12 22:05:00');

-- Lieux 1 à 3 : lieux par défaut (sans auteur)
INSERT INTO spots (id, name, description, latitude, longitude, altitude, is_free, status, refusal_reason, created_at, user_id, canton_code, access_type_id) VALUES
(1,  'Lac de Taney', 'Petit lac de montagne accessible uniquement à pied depuis Le Flon. Replat herbeux idéal pour une tente, vue sur les Jumelles.', 46.337500, 6.830600, 1408, TRUE,  'published', NULL, '2026-05-01 10:00:00', NULL, 'VS', 3),
(2,  'Col du Marchairuz', 'Grand parking au sommet du col, plat et calme la nuit. Restaurant à proximité.', 46.552800, 6.255000, 1447, TRUE,  'published', NULL, '2026-05-01 10:05:00', NULL, 'VD', 1),
(3,  'Col du Grimsel – parking du lac', 'Parking au bord du Totensee, très fréquenté en été. Nuits fraîches même en août.', 46.561700, 8.337200, 2165, TRUE,  'published', NULL, '2026-05-01 10:10:00', NULL, 'BE', 1),
(4,  'Aire camping-car du Pont', 'Aire aménagée au bord du lac de Joux : vidange, eau potable et bornes électriques. Paiement à l''horodateur.', 46.666700, 6.333300, 1008, FALSE, 'published', NULL, '2026-09-06 19:02:00', 2, 'VD', 1),
(5,  'Barrage de Moiry', 'Grande esplanade au pied du barrage, départ de randonnées vers le glacier de Moiry.', 46.141400, 7.586900, 2249, TRUE,  'published', NULL, '2026-09-08 16:40:00', 3, 'VS', 1),
(6,  'Lago Ritom', 'Piste carrossable depuis Piora, quelques emplacements plats au-dessus du lac. 4x4 conseillé par temps humide.', 46.535000, 8.690000, 1850, TRUE,  'published', NULL, '2026-09-12 12:15:00', 3, 'TI', 2),
(7,  'Oberalppass', 'Large parking at the top of the pass, next to the lighthouse. Can be windy at night.', 46.658900, 8.671100, 2044, TRUE,  'published', NULL, '2026-09-14 08:30:00', 4, 'GR', 1),
(8,  'Sihlsee – Euthal', 'Aire au bord du lac avec toilettes et point d''eau. Taxe de séjour à payer sur place.', 47.130000, 8.780000, 890, FALSE, 'published', NULL, '2026-09-18 17:55:00', 4, 'SZ', 1),
(9,  'Chasseral – Les Pontins', 'Prairie en bordure de piste forestière, vue sur les Alpes au lever du soleil. Emplacement de feu existant.', 47.133000, 7.059000, 1548, TRUE,  'published', NULL, '2026-09-20 21:10:00', 2, 'BE', 2),
(10, 'Creux du Van', 'Bivouac au bord du cirque rocheux, magnifique coucher de soleil.', 46.933600, 6.727200, 1350, TRUE,  'refused', 'Le Creux du Van est une réserve naturelle : le camping et le bivouac y sont interdits.', '2026-09-25 14:20:00', 5, 'NE', 3),
(11, 'Étang de la Gruère', 'Clairière à 10 minutes à pied du parking, à l''écart du sentier principal.', 47.240000, 7.050000, 1000, TRUE,  'pending', NULL, '2026-10-10 18:45:00', 2, 'JU', 3),
(12, 'Klausenpass – Urnerboden', 'Track leading to a flat spot above the Urnerboden plain. High clearance recommended.', 46.868600, 8.855000, 1948, TRUE,  'pending', NULL, '2026-10-11 09:05:00', 3, 'UR', 2);

INSERT INTO spot_accommodation_types (spot_id, accommodation_type_id) VALUES
(1,1),
(2,2), (2,3),
(3,2), (3,3),
(4,3),
(5,1), (5,2), (5,3),
(6,1), (6,2),
(7,2), (7,3),
(8,3),
(9,1), (9,2),
(10,1),
(11,1),
(12,1), (12,2);

INSERT INTO spot_amenities (spot_id, amenity_id) VALUES
(1,1),
(2,2),
(3,2),
(4,1), (4,2), (4,4),
(5,1), (5,2),
(6,1), (6,3),
(7,2),
(8,1), (8,2),
(9,3),
(11,1);

-- Avis uniquement sur des lieux publiés, un seul par (utilisateur, lieu)
INSERT INTO reviews (rating, comment, visit_date, created_at, user_id, spot_id) VALUES
(5, 'Endroit magique, très calme. Eau du ruisseau à filtrer.',                      '2026-07-18', '2026-07-20 19:00:00', 2, 1),
(4, 'Superbe mais beaucoup de monde le week-end.',                                  '2026-08-09', '2026-08-10 08:30:00', 3, 1),
(5, 'Quiet lake, perfect for a night in the tent.',                                '2026-08-22', '2026-08-23 10:12:00', 4, 1),
(4, 'Parking plat, idéal pour une nuit de passage.',                                '2026-08-02', '2026-08-03 07:40:00', 2, 2),
(3, 'Un peu de bruit de voitures en début de soirée.',                              '2026-09-07', '2026-09-08 09:15:00', 4, 2),
(4, 'Vue incroyable au réveil, mais il faisait 2 °C.',                              '2026-08-14', '2026-08-15 08:00:00', 3, 3),
(5, 'Stunning spot, toilets were clean.',                                          '2026-08-30', '2026-08-31 18:20:00', 4, 3),
(4, 'Aire bien équipée, électricité fonctionnelle.',                                '2026-09-12', '2026-09-13 11:00:00', 3, 4),
(3, 'Pratique mais un peu cher pour ce que c''est.',                                '2026-09-20', '2026-09-21 09:45:00', 4, 4),
(5, 'Nuit étoilée exceptionnelle au pied du barrage.',                              '2026-09-09', '2026-09-10 08:10:00', 2, 5),
(4, 'Grand espace, facile pour un camping-car.',                                    '2026-09-15', '2026-09-16 07:30:00', 4, 5),
(5, 'Piste en bon état, emplacements très calmes.',                                 '2026-09-13', '2026-09-14 12:00:00', 2, 6),
(4, 'Beautiful lake, the track is fine with a 4x4.',                               '2026-09-27', '2026-09-28 16:45:00', 4, 6),
(3, 'Venteux, mais vue magnifique sur la vallée.',                                  '2026-09-16', '2026-09-17 08:05:00', 2, 7),
(4, 'Bon spot pour une nuit, phare original.',                                      '2026-09-21', '2026-09-22 09:00:00', 3, 7),
(4, 'Calme et propre, taxe raisonnable.',                                           '2026-09-23', '2026-09-24 10:30:00', 3, 8),
(5, 'Lever de soleil sur les Alpes inoubliable.',                                   '2026-09-26', '2026-09-27 07:50:00', 3, 9),
(4, 'Nice meadow, we used the existing fire ring.',                                '2026-10-03', '2026-10-04 11:15:00', 4, 9),
(2, 'Accès difficile de nuit, pas trouvé l''emplacement de feu.',                   '2026-10-05', '2026-10-06 20:00:00', 1, 9),
(4, 'Très bien pour se reposer après la route.',                                    '2026-10-08', '2026-10-09 08:40:00', 5, 2);

INSERT INTO favorites (user_id, spot_id, created_at) VALUES
(2, 5, '2026-09-10 08:15:00'),
(2, 6, '2026-09-14 12:05:00'),
(2, 3, '2026-09-22 19:30:00'),
(3, 1, '2026-08-10 08:35:00'),
(3, 9, '2026-09-27 07:55:00'),
(3, 6, '2026-09-28 09:00:00'),
(4, 1, '2026-08-23 10:15:00'),
(4, 7, '2026-09-15 18:00:00'),
(4, 8, '2026-09-24 21:10:00'),
(5, 2, '2026-10-09 08:45:00');
