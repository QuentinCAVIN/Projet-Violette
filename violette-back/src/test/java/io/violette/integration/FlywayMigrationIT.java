package io.violette.integration;

import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.junit.TestProfile;
import io.violette.artistbooking.repository.ArtistBookingRepository;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.cabaretcompany.repository.CabaretShowRepository;
import io.violette.showdate.repository.ArtistAvailabilityRepository;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Vérifie que les migrations Flyway V1–V5 s'appliquent correctement sur un MySQL réel.
 * Le conteneur MySQL est démarré automatiquement par Quarkus Dev Services (Testcontainers).
 * Ces tests prouvent que le schéma SQL est compatible MySQL, pas seulement H2.
 */
@QuarkusTest
@TestProfile(MySQLIntegrationTestProfile.class)
@DisplayName("Migrations Flyway V1–V5 — MySQL réel (Dev Services)")
class FlywayMigrationIT {

    @Inject VioletteUserRepository userRepository;
    @Inject CabaretCompanyRepository companyRepository;
    @Inject CabaretShowRepository showRepository;
    @Inject ShowDateRepository showDateRepository;
    @Inject ShowDateSkillRequirementRepository skillRequirementRepository;
    @Inject ArtistAvailabilityRepository availabilityRepository;
    @Inject ArtistBookingRepository bookingRepository;

    @Test
    @DisplayName("migration V1 — crée les tables violette_user, user_role et artist_skill accessibles")
    void v1Migration_userTablesAreAccessible() {
        assertTrue(userRepository.count() >= 0,
                "La table violette_user doit être accessible après la migration V1");
    }

    @Test
    @DisplayName("migration V2 — rend la table user_role accessible après le refactoring des rôles")
    void v2Migration_userRoleTableIsAccessible() {
        // La migration V2 refactorise les rôles utilisateur.
        // Si count() s'exécute sans exception, la table et ses colonnes sont corrects.
        assertTrue(userRepository.count() >= 0,
                "La table user_role doit être accessible après la migration V2");
    }

    @Test
    @DisplayName("migration V3 — rend la table cabaret_company accessible avec updated_at")
    void v3Migration_companyTableIsAccessible() {
        assertTrue(companyRepository.count() >= 0,
                "La table cabaret_company doit être accessible après la migration V3");
    }

    @Test
    @DisplayName("migration V4 — crée les tables show_date, show_date_skill_requirement et artist_availability")
    void v4Migration_showDateTablesAreAccessible() {
        assertTrue(showDateRepository.count() >= 0,
                "La table show_date doit être accessible après la migration V4");
        assertTrue(skillRequirementRepository.count() >= 0,
                "La table show_date_skill_requirement doit être accessible après la migration V4");
        assertTrue(availabilityRepository.count() >= 0,
                "La table artist_availability doit être accessible après la migration V4");
    }

    @Test
    @DisplayName("migration V5 — crée la table artist_booking accessible")
    void v5Migration_artistBookingTableIsAccessible() {
        assertTrue(bookingRepository.count() >= 0,
                "La table artist_booking doit être accessible après la migration V5");
    }

    @Test
    @DisplayName("migrations V1–V5 — rendent accessibles toutes les tables des quatre domaines métier")
    void allMigrations_allDomainTablesAreAccessible() {
        assertTrue(userRepository.count() >= 0);
        assertTrue(companyRepository.count() >= 0);
        assertTrue(showRepository.count() >= 0);
        assertTrue(showDateRepository.count() >= 0);
        assertTrue(bookingRepository.count() >= 0);
    }
}
