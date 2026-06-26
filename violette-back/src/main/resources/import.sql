-- ==============================================================
-- Seed de développement local (H2, profils dev et firebase)
-- ==============================================================
-- Exécuté par Hibernate après drop-and-create (import.sql).
-- La base est recréée à chaque démarrage : pas de gestion de doublons nécessaire.
--
-- Ordre d'exécution au démarrage :
--   1. Hibernate crée le schéma (drop-and-create)
--   2. Ce script (import.sql)
--   3. StartupEvent → DefaultCompanyBootstrapService.ensureDefaultCompanyExists()
--      → trouve déjà "Dream's Production" par nom → aucun doublon créé
--
-- Remplacer les placeholders firebase_uid par vos UID Firebase réels avant test.
-- ==============================================================

-- --------------------------------------------------------------
-- Utilisateurs (violette_user)
-- Colonnes NOT NULL : firebase_uid, email, first_name, last_name, created_at, updated_at
-- --------------------------------------------------------------

INSERT INTO violette_user (id, firebase_uid, email, first_name, last_name, created_at, updated_at)
VALUES (1, 'REMPLACER_PAR_UID_MANAGER', 'manager@violette.test', 'Marie', 'Gérant',
        TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO violette_user (id, firebase_uid, email, first_name, last_name, created_at, updated_at)
VALUES (2, 'REMPLACER_PAR_UID_ARTISTE_1', 'artiste1@violette.test', 'Léa', 'Danse',
        TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO violette_user (id, firebase_uid, email, first_name, last_name, created_at, updated_at)
VALUES (3, 'REMPLACER_PAR_UID_ARTISTE_2', 'artiste2@violette.test', 'Hugo', 'Chant',
        TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

-- --------------------------------------------------------------
-- Rôles (user_role) — @ElementCollection, enum STRING : ARTIST | MANAGER
-- --------------------------------------------------------------

INSERT INTO user_role (user_id, role) VALUES (1, 'MANAGER');
INSERT INTO user_role (user_id, role) VALUES (2, 'ARTIST');
INSERT INTO user_role (user_id, role) VALUES (3, 'ARTIST');

-- --------------------------------------------------------------
-- Compétences artistes (artist_skill) — enum STRING : DANCE | SINGING | STILT_WALKING | ACROBATICS
-- --------------------------------------------------------------

INSERT INTO artist_skill (user_id, skill) VALUES (2, 'DANCE');
INSERT INTO artist_skill (user_id, skill) VALUES (3, 'SINGING');

-- --------------------------------------------------------------
-- Compagnie (cabaret_company)
-- Nom aligné sur CabaretCompanyService.DEFAULT_COMPANY_NAME pour le bootstrap
-- --------------------------------------------------------------

INSERT INTO cabaret_company (id, name, description, manager_id, created_at, updated_at)
VALUES (1, 'Dream''s Production',
        'Compagnie bootstrap temporaire v0.4.0 (sera remplacée en v0.5.0).',
        1, TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

-- --------------------------------------------------------------
-- Membres artistes (company_member) — PK composite (company_id, artist_id)
-- Requis pour que GET /show-dates/me/available filtre par appartenance
-- --------------------------------------------------------------

INSERT INTO company_member (company_id, artist_id, joined_at)
VALUES (1, 2, TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO company_member (company_id, artist_id, joined_at)
VALUES (1, 3, TIMESTAMP '2026-01-15 12:00:00');

-- --------------------------------------------------------------
-- Dates de spectacle (show_date) — novembre 2026
-- Statuts visibles artiste : OPTION | CONFIRMED | STAFFED (pas INQUIRY)
-- Colonnes NOT NULL : company_id, event_date, meeting_time, location,
--                     client_contact_name, client_contact_phone, status,
--                     created_at, updated_at
-- --------------------------------------------------------------

INSERT INTO show_date (id, company_id, revue_id, event_date, meeting_time, location,
                       client_contact_name, client_contact_phone, show_details, status,
                       created_at, updated_at)
VALUES (1, 1, NULL, DATE '2026-11-08', TIME '18:00:00',
        'Cabaret des Lilas, 16 rue de Belleville, 75020 Paris',
        'Sophie Martin', '06 12 34 56 78',
        'Soirée cabaret classique — numéros danse et chant.',
        'OPTION', TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO show_date (id, company_id, revue_id, event_date, meeting_time, location,
                       client_contact_name, client_contact_phone, show_details, status,
                       created_at, updated_at)
VALUES (2, 1, NULL, DATE '2026-11-15', TIME '19:30:00',
        'Salle Pleyel, 252 rue du Faubourg Saint-Honoré, 75008 Paris',
        'Jean Dupont', '06 98 76 54 32',
        'Gala de fin d''année — dress code glamour.',
        'OPTION', TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO show_date (id, company_id, revue_id, event_date, meeting_time, location,
                       client_contact_name, client_contact_phone, show_details, status,
                       created_at, updated_at)
VALUES (3, 1, NULL, DATE '2026-11-22', TIME '20:00:00',
        'Théâtre du Châtelet, 1 place du Châtelet, 75001 Paris',
        'Claire Bernard', '01 40 28 28 40',
        'Prestation confirmée — mise en place dès 17h.',
        'CONFIRMED', TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO show_date (id, company_id, revue_id, event_date, meeting_time, location,
                       client_contact_name, client_contact_phone, show_details, status,
                       created_at, updated_at)
VALUES (4, 1, NULL, DATE '2026-11-29', TIME '18:30:00',
        'Le Trianon, 80 boulevard de Rochechouart, 75018 Paris',
        'Marc Lefebvre', '06 11 22 33 44',
        'Soirée thématique années folles.',
        'OPTION', TIMESTAMP '2026-01-15 12:00:00', TIMESTAMP '2026-01-15 12:00:00');

-- --------------------------------------------------------------
-- Disponibilités artistes (artist_availability) — PK composite (show_date_id, artist_id)
-- enum STRING : PENDING | AVAILABLE | IF_NEEDED | UNAVAILABLE
-- --------------------------------------------------------------

INSERT INTO artist_availability (show_date_id, artist_id, status, updated_at)
VALUES (1, 2, 'AVAILABLE', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO artist_availability (show_date_id, artist_id, status, updated_at)
VALUES (2, 2, 'IF_NEEDED', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO artist_availability (show_date_id, artist_id, status, updated_at)
VALUES (3, 2, 'PENDING', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO artist_availability (show_date_id, artist_id, status, updated_at)
VALUES (1, 3, 'UNAVAILABLE', TIMESTAMP '2026-01-15 12:00:00');

INSERT INTO artist_availability (show_date_id, artist_id, status, updated_at)
VALUES (4, 3, 'AVAILABLE', TIMESTAMP '2026-01-15 12:00:00');

-- --------------------------------------------------------------
-- Réalignement des identifiants auto-générés (H2 IDENTITY)
-- --------------------------------------------------------------

ALTER TABLE violette_user ALTER COLUMN id RESTART WITH 4;
ALTER TABLE cabaret_company ALTER COLUMN id RESTART WITH 2;
ALTER TABLE show_date ALTER COLUMN id RESTART WITH 5;
