-- ==============================================================
-- Violette Database - Migration V7 : Renommage des valeurs de ShowDateStatus
-- ==============================================================
-- Aligne la colonne show_date.status sur le nouveau cycle de vie métier :
--   PENDING  → INQUIRY   (demande client à qualifier)
--   OPTIONAL → OPTION    (devis envoyé / option posée)
--   LOCKED   → STAFFED   (équipe complète et sécurisée)
--   CONFIRMED et CANCELLED : conservés
--   ARCHIVED : nouveau statut ajouté (prestation passée / historisée)
--
-- Stratégie en 3 étapes pour garantir la compatibilité avec les données existantes :
--   1. Agrandir l'ENUM pour inclure les nouvelles valeurs (sans perdre les anciennes)
--   2. Migrer les données ligne par ligne
--   3. Réduire l'ENUM aux nouvelles valeurs uniquement
-- ==============================================================

-- Étape 1 : inclure simultanément anciennes et nouvelles valeurs
ALTER TABLE show_date
    MODIFY COLUMN status
        ENUM('PENDING', 'OPTIONAL', 'CONFIRMED', 'LOCKED', 'CANCELLED', 'INQUIRY', 'OPTION', 'STAFFED', 'ARCHIVED')
        NOT NULL DEFAULT 'INQUIRY';

-- Étape 2 : migrer les lignes existantes vers les nouvelles valeurs
UPDATE show_date SET status = 'INQUIRY' WHERE status = 'PENDING';
UPDATE show_date SET status = 'OPTION'  WHERE status = 'OPTIONAL';
UPDATE show_date SET status = 'STAFFED' WHERE status = 'LOCKED';

-- Étape 3 : retirer les anciennes valeurs de l'ENUM
ALTER TABLE show_date
    MODIFY COLUMN status
        ENUM('INQUIRY', 'OPTION', 'CONFIRMED', 'STAFFED', 'CANCELLED', 'ARCHIVED')
        NOT NULL DEFAULT 'INQUIRY';
