-- ==============================================================
-- Violette Database - Migration V6 : Refactor showdate + availability status
-- ==============================================================
-- Objectifs :
-- 1) show_date : remplacer address + venue_name par location
-- 2) artist_availability.status : renommer CONDITIONAL -> IF_NEEDED
--
-- Ordre de migration ENUM MySQL (sécurisé) :
-- - ajouter temporairement IF_NEEDED dans l'ENUM
-- - migrer les données CONDITIONAL vers IF_NEEDED
-- - retirer ensuite CONDITIONAL de l'ENUM final
-- ==============================================================

-- --------------------------------------------------------------
-- DOMAINE : showdate — table principale
-- --------------------------------------------------------------

ALTER TABLE show_date
    CHANGE COLUMN address location VARCHAR(500) NOT NULL;

ALTER TABLE show_date
    DROP COLUMN venue_name;

-- --------------------------------------------------------------
-- DOMAINE : showdate — disponibilités artistes
-- --------------------------------------------------------------

-- Étape 1 : élargir temporairement l'ENUM pour accepter IF_NEEDED
ALTER TABLE artist_availability
    MODIFY COLUMN status ENUM('PENDING', 'AVAILABLE', 'CONDITIONAL', 'IF_NEEDED', 'UNAVAILABLE')
        NOT NULL DEFAULT 'PENDING';

-- Étape 2 : migrer les données existantes
UPDATE artist_availability
SET status = 'IF_NEEDED'
WHERE status = 'CONDITIONAL';

-- Étape 3 : supprimer l'ancienne valeur de l'ENUM
ALTER TABLE artist_availability
    MODIFY COLUMN status ENUM('PENDING', 'AVAILABLE', 'IF_NEEDED', 'UNAVAILABLE')
        NOT NULL DEFAULT 'PENDING';
