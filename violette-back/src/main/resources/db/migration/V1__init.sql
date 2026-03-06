-- ==============================================================
-- Violette Database - Migration V1 : Schéma initial
-- ==============================================================
-- Domaines couverts :
--   - violetteuser    : utilisateurs (artistes, gérants)
--   - cabaretcompany  : compagnies, membres, revues
--   - showdate        : dates de spectacle, disponibilités artistes
--   - artistbooking   : réservations artistes
--
-- Conventions :
--   - snake_case pour tous les noms de tables et colonnes
--   - Clés primaires auto-incrémentées (BIGINT)
--   - Clés étrangères nommées explicitement (fk_<table>_<ref>)
--   - Contraintes d'unicité nommées (uk_<table>_<champ>)
--   - Index nommés (idx_<table>_<champ>)
--   - Pas de champ selectedCount (calculé par COUNT SQL)
-- ==============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ==============================================================
-- DOMAINE : violetteuser
-- ==============================================================

CREATE TABLE violette_user (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    firebase_uid VARCHAR(128) NOT NULL COMMENT 'UID Firebase Auth - clé de liaison avec le frontend',
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    email        VARCHAR(255) NOT NULL,
    role         ENUM('ARTIST', 'MANAGER') NOT NULL COMMENT 'Rôle principal. Un gérant peut aussi être artiste via la table artist_skill.',
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uk_user_firebase_uid UNIQUE (firebase_uid),
    CONSTRAINT uk_user_email        UNIQUE (email),

    INDEX idx_user_role (role)
) COMMENT='Utilisateurs de la plateforme (artistes et gérants)';


CREATE TABLE artist_skill (
    user_id BIGINT NOT NULL,
    skill   ENUM('DANCE', 'SINGING', 'STILT_WALKING', 'ACROBATICS') NOT NULL
            COMMENT 'Compétences artistiques. Uniquement pour les utilisateurs avec rôle ARTIST.',

    PRIMARY KEY (user_id, skill),
    CONSTRAINT fk_artist_skill_user FOREIGN KEY (user_id)
        REFERENCES violette_user(id) ON DELETE CASCADE
) COMMENT='Compétences artistiques par utilisateur';


-- ==============================================================
-- DOMAINE : cabaretcompany
-- ==============================================================

CREATE TABLE cabaret_company (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    manager_id  BIGINT       NOT NULL COMMENT 'Gérant responsable de la compagnie',
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT fk_company_manager FOREIGN KEY (manager_id)
        REFERENCES violette_user(id),

    INDEX idx_company_manager (manager_id)
) COMMENT='Compagnies de cabaret. Chaque compagnie est gérée par un gérant unique.';


CREATE TABLE company_member (
    company_id BIGINT    NOT NULL,
    artist_id  BIGINT    NOT NULL COMMENT 'Artiste membre de la compagnie',
    joined_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (company_id, artist_id),
    CONSTRAINT fk_member_company FOREIGN KEY (company_id)
        REFERENCES cabaret_company(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_artist FOREIGN KEY (artist_id)
        REFERENCES violette_user(id) ON DELETE CASCADE,

    INDEX idx_member_artist (artist_id)
) COMMENT='Membres artistes d''une compagnie de cabaret';


CREATE TABLE revue (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    title       VARCHAR(255) NOT NULL COMMENT 'Titre de la revue',
    description TEXT,
    company_id  BIGINT       NOT NULL,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT fk_revue_company FOREIGN KEY (company_id)
        REFERENCES cabaret_company(id),

    INDEX idx_revue_company (company_id)
) COMMENT='Revues appartenant à une compagnie. Une compagnie doit avoir au moins une revue.';


-- ==============================================================
-- DOMAINE : showdate
-- ==============================================================

CREATE TABLE show_date (
    id                     BIGINT         NOT NULL AUTO_INCREMENT,
    title                  VARCHAR(255)   NOT NULL,
    event_date             DATE           NOT NULL COMMENT 'Date du spectacle (sans heure)',
    start_time             TIME           NOT NULL COMMENT 'Heure de début (heure locale)',
    end_time               TIME           NOT NULL COMMENT 'Heure de fin. La durée ne peut pas dépasser 12H.',
    address                VARCHAR(500)   NOT NULL,
    required_artists_count INT            NOT NULL COMMENT 'Nombre d''artistes nécessaires pour ce spectacle',
    fee_per_artist         DECIMAL(10, 2) NOT NULL COMMENT 'Montant du cachet par artiste (en euros)',
    description            TEXT,
    status                 ENUM('PENDING', 'OPTIONAL', 'CONFIRMED', 'CANCELLED', 'LOCKED') NOT NULL DEFAULT 'PENDING',
    company_id             BIGINT         NOT NULL,
    revue_id               BIGINT         COMMENT 'Revue jouée lors de cette date (nullable : peut être défini après création)',
    created_at             TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT fk_show_date_company      FOREIGN KEY (company_id)      REFERENCES cabaret_company(id),
    CONSTRAINT fk_show_date_revue        FOREIGN KEY (revue_id)        REFERENCES revue(id) ON DELETE SET NULL,
    CONSTRAINT chk_show_date_times       CHECK (end_time > start_time),
    CONSTRAINT chk_artists_count         CHECK (required_artists_count > 0),
    CONSTRAINT chk_fee_per_artist        CHECK (fee_per_artist >= 0),

    INDEX idx_show_date_company    (company_id),
    INDEX idx_show_date_event_date (event_date),
    INDEX idx_show_date_status     (status)
) COMMENT='Dates de spectacle. La durée ne peut pas dépasser 12H (règle cachet intermittence).';


CREATE TABLE artist_availability (
    id           BIGINT    NOT NULL AUTO_INCREMENT,
    show_date_id BIGINT    NOT NULL,
    artist_id    BIGINT    NOT NULL,
    status       ENUM('PENDING', 'AVAILABLE', 'CONDITIONAL', 'UNAVAILABLE') NOT NULL DEFAULT 'PENDING',
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT uk_availability           UNIQUE (show_date_id, artist_id),
    CONSTRAINT fk_availability_show_date FOREIGN KEY (show_date_id) REFERENCES show_date(id) ON DELETE CASCADE,
    CONSTRAINT fk_availability_artist    FOREIGN KEY (artist_id)    REFERENCES violette_user(id) ON DELETE CASCADE,

    INDEX idx_availability_artist (artist_id),
    INDEX idx_availability_status (status)
) COMMENT='Disponibilités déclarées par les artistes sur les dates de spectacle. Remplace la map Firestore dénormalisée.';


-- ==============================================================
-- DOMAINE : artistbooking
-- ==============================================================

CREATE TABLE artist_booking (
    id           BIGINT    NOT NULL AUTO_INCREMENT,
    show_date_id BIGINT    NOT NULL,
    artist_id    BIGINT    NOT NULL,
    status       ENUM('SELECTED', 'PENDING_CONFIRMATION', 'CONFIRMED', 'REFUSED') NOT NULL DEFAULT 'SELECTED',
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    requested_at TIMESTAMP NULL     DEFAULT NULL COMMENT 'Date d''envoi de la demande de confirmation au gérant',
    responded_at TIMESTAMP NULL     DEFAULT NULL COMMENT 'Date de réponse de l''artiste',

    PRIMARY KEY (id),
    CONSTRAINT uk_booking           UNIQUE (show_date_id, artist_id),
    CONSTRAINT fk_booking_show_date FOREIGN KEY (show_date_id) REFERENCES show_date(id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_artist    FOREIGN KEY (artist_id)    REFERENCES violette_user(id) ON DELETE CASCADE,

    INDEX idx_booking_artist        (artist_id),
    INDEX idx_booking_status        (status),
    INDEX idx_booking_artist_status (artist_id, status) COMMENT 'Optimise la requête : toutes les réservations en attente pour un artiste donné'
) COMMENT='Réservations d''artistes sur des dates de spectacle. Un artiste ne peut être réservé qu''une fois par date.';


SET FOREIGN_KEY_CHECKS = 1;
