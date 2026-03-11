-- ==============================================================
-- Violette Database - Migration V4 : Refonte du domaine showdate
-- ==============================================================
-- Remplace le schéma show_date de V1 (structure simplifiée avec title/fee globale)
-- par le modèle métier complet avec :
--   - feuille de route (coordonnées client, heure de rendez-vous, lieu)
--   - besoins par compétence artistique (show_date_skill_requirement)
--   - disponibilités artistes avec clé composite (artist_availability)
--
-- artist_booking : supprimée ici car elle référence show_date via FK.
-- Elle sera recréée par la migration du domaine artistbooking (V5+).
-- Cette migration ne recrée PAS artist_booking — ce n'est pas sa responsabilité.
-- ==============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- --------------------------------------------------------------
-- Suppression des tables qui dépendent de show_date (V1)
-- artist_booking est supprimée uniquement pour libérer la FK vers show_date.
-- Sa recréation appartient au domaine artistbooking.
-- --------------------------------------------------------------

DROP TABLE IF EXISTS artist_booking;
DROP TABLE IF EXISTS artist_availability;
DROP TABLE IF EXISTS show_date;

-- --------------------------------------------------------------
-- DOMAINE : showdate — table principale
-- --------------------------------------------------------------

CREATE TABLE show_date (
    id                   BIGINT       NOT NULL AUTO_INCREMENT,
    company_id           BIGINT       NOT NULL                  COMMENT 'Compagnie organisatrice',
    revue_id             BIGINT       NULL                      COMMENT 'Revue jouée lors de cette date (nullable)',
    event_date           DATE         NOT NULL                  COMMENT 'Date du spectacle',
    meeting_time         TIME         NOT NULL                  COMMENT 'Heure de rendez-vous / appel',
    venue_name           VARCHAR(255) NULL                      COMMENT 'Nom du lieu (optionnel)',
    address              VARCHAR(500) NOT NULL,
    client_contact_name  VARCHAR(255) NOT NULL,
    client_contact_phone VARCHAR(50)  NOT NULL,
    show_details         TEXT         NULL                      COMMENT 'Détails du spectacle (public, décor, consignes)',
    status               ENUM('PENDING', 'OPTIONAL', 'CONFIRMED', 'LOCKED', 'CANCELLED')
                             NOT NULL DEFAULT 'PENDING',
    created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (id),
    CONSTRAINT fk_show_date_company FOREIGN KEY (company_id) REFERENCES cabaret_company(id),
    CONSTRAINT fk_show_date_revue   FOREIGN KEY (revue_id)   REFERENCES revue(id) ON DELETE SET NULL,

    INDEX idx_show_date_company    (company_id),
    INDEX idx_show_date_event_date (event_date),
    INDEX idx_show_date_status     (status)
) COMMENT='Dates de spectacle (feuilles de route). Remplace le schéma V1.';


-- --------------------------------------------------------------
-- Besoins artistiques par compétence pour une date
-- --------------------------------------------------------------

CREATE TABLE show_date_skill_requirement (
    id             BIGINT         NOT NULL AUTO_INCREMENT,
    show_date_id   BIGINT         NOT NULL,
    skill          ENUM('DANCE', 'SINGING', 'STILT_WALKING', 'ACROBATICS') NOT NULL,
    required_count INT            NOT NULL COMMENT 'Nombre d''artistes nécessaires pour cette compétence',
    net_fee        DECIMAL(10, 2) NOT NULL COMMENT 'Cachet net par artiste pour cette compétence (en euros)',

    PRIMARY KEY (id),
    CONSTRAINT uk_skill_requirement         UNIQUE (show_date_id, skill),
    CONSTRAINT fk_skill_req_show_date       FOREIGN KEY (show_date_id) REFERENCES show_date(id) ON DELETE CASCADE,
    CONSTRAINT chk_skill_req_required_count CHECK (required_count > 0),
    CONSTRAINT chk_skill_req_net_fee        CHECK (net_fee >= 0),

    INDEX idx_skill_req_show_date (show_date_id)
) COMMENT='Besoins artistiques par compétence pour une date de spectacle';


-- --------------------------------------------------------------
-- Disponibilités artistes — clé composite (show_date_id, artist_id)
-- Remplace la structure V1 avec id auto-increment + contrainte unique
-- --------------------------------------------------------------

CREATE TABLE artist_availability (
    show_date_id BIGINT    NOT NULL,
    artist_id    BIGINT    NOT NULL,
    status       ENUM('PENDING', 'AVAILABLE', 'CONDITIONAL', 'UNAVAILABLE')
                     NOT NULL DEFAULT 'PENDING',
    updated_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (show_date_id, artist_id),
    CONSTRAINT fk_availability_show_date FOREIGN KEY (show_date_id) REFERENCES show_date(id) ON DELETE CASCADE,
    CONSTRAINT fk_availability_artist    FOREIGN KEY (artist_id)    REFERENCES violette_user(id) ON DELETE CASCADE,

    INDEX idx_availability_artist (artist_id),
    INDEX idx_availability_status (status)
) COMMENT='Disponibilités déclarées par les artistes. Clé composite — remplace la Map Firestore dénormalisée.';


SET FOREIGN_KEY_CHECKS = 1;

-- artist_booking sera créée par la migration V5+ du domaine artistbooking.
