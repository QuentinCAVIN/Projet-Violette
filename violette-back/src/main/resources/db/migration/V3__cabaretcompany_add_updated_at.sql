-- ==============================================================
-- Violette Database - Migration V3 : Ajout updated_at sur cabaretcompany
-- ==============================================================
-- Complète le schéma V1 en ajoutant updated_at sur les tables
-- cabaret_company et revue, absentes de la migration initiale.
-- ==============================================================

ALTER TABLE cabaret_company
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    AFTER created_at;

ALTER TABLE revue
    ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    AFTER created_at;
