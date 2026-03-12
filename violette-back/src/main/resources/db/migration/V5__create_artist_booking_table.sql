-- ==============================================================
-- Violette Database - Migration V5 : Domaine artistbooking
-- ==============================================================
-- Crée la table artist_booking, supprimée en V4 lors de la refonte du domaine showdate.
--
-- Un ArtistBooking représente un artiste retenu pour une date afin de couvrir
-- un besoin artistique spécifique (ShowDateSkillRequirement).
--
-- Contrainte d'unicité : un artiste ne peut être réservé qu'une seule fois par date.
-- Le champ agreed_net_fee est un snapshot du cachet au moment de la sélection
-- (indépendant d'une modification ultérieure de show_date_skill_requirement.net_fee).
-- ==============================================================

CREATE TABLE artist_booking (
    id                   BIGINT         NOT NULL AUTO_INCREMENT,
    show_date_id         BIGINT         NOT NULL                  COMMENT 'Date de spectacle concernée',
    artist_id            BIGINT         NOT NULL                  COMMENT 'Artiste réservé',
    skill_requirement_id BIGINT         NULL                      COMMENT 'Besoin artistique couvert (nullable — lien optionnel)',
    status               ENUM(
                             'SELECTED',
                             'PENDING_CONFIRMATION',
                             'CONFIRMED',
                             'REFUSED',
                             'CANCELLED'
                         )              NOT NULL DEFAULT 'SELECTED' COMMENT 'Statut du cycle de réservation',
    agreed_net_fee       DECIMAL(10, 2) NULL                      COMMENT 'Snapshot du cachet net au moment de la sélection (en euros)',

    -- BookingTimeline : horodatages du cycle de vie
    created_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    requested_at         TIMESTAMP      NULL                      COMMENT 'Date d''envoi de la demande de confirmation (SELECTED → PENDING_CONFIRMATION)',
    responded_at         TIMESTAMP      NULL                      COMMENT 'Date de réponse de l''artiste (PENDING_CONFIRMATION → CONFIRMED | REFUSED)',

    PRIMARY KEY (id),

    -- Unicité : un artiste ne peut être réservé qu'une seule fois par date
    CONSTRAINT uk_booking_artist_date UNIQUE (show_date_id, artist_id),

    -- Clés étrangères explicitement nommées (convention du projet)
    CONSTRAINT fk_booking_show_date          FOREIGN KEY (show_date_id)         REFERENCES show_date(id)                    ON DELETE CASCADE,
    CONSTRAINT fk_booking_artist             FOREIGN KEY (artist_id)            REFERENCES violette_user(id),
    CONSTRAINT fk_booking_skill_requirement  FOREIGN KEY (skill_requirement_id) REFERENCES show_date_skill_requirement(id)  ON DELETE SET NULL,

    -- Index sur les colonnes fréquemment filtrées
    INDEX idx_booking_show_date              (show_date_id),
    INDEX idx_booking_artist                 (artist_id),
    INDEX idx_booking_status                 (status),
    INDEX idx_booking_artist_status          (artist_id, status),
    INDEX idx_booking_skill_requirement      (skill_requirement_id)

) COMMENT='Réservations artistes. Source de vérité des artistes présents sur une ShowDate.';
