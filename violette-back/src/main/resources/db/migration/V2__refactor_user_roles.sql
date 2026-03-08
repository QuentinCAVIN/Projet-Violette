-- ==============================================================
-- Violette Database - Migration V2 : Rôles multiples par utilisateur
-- ==============================================================
-- Remplace la colonne unique role de violette_user par une table
-- user_role (user_id, role) pour permettre plusieurs rôles par utilisateur.
-- Conventions : fk_<table>_<ref>, idx_<table>_<champ>
-- ==============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Supprimer la colonne role (l'index idx_user_role est supprimé avec elle)
ALTER TABLE violette_user DROP COLUMN role;

-- Table de jointure : un utilisateur peut avoir plusieurs rôles
CREATE TABLE user_role (
    user_id BIGINT       NOT NULL,
    role    ENUM('ARTIST', 'MANAGER') NOT NULL
            COMMENT 'Rôle utilisateur. Un même utilisateur peut cumuler ARTIST et MANAGER.',

    PRIMARY KEY (user_id, role),
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id)
        REFERENCES violette_user(id) ON DELETE CASCADE,

    INDEX idx_user_role_user (user_id)
) COMMENT='Rôles des utilisateurs (plusieurs rôles possibles par utilisateur)';

SET FOREIGN_KEY_CHECKS = 1;
