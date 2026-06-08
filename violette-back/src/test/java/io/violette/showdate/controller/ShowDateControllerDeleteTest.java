package io.violette.showdate.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.UserTransaction;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Set;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

/**
 * Tests de l'endpoint DELETE sur {@link ShowDateController}.
 *
 * <p>Limite assumée : on ne valide pas ici les cascades SQL profondes
 * ({@code artist_availability}, {@code artist_booking}, {@code show_date_skill_requirement}),
 * car l'environnement H2/JPA de test ne reflète pas fidèlement les contraintes
 * Flyway/MySQL de prod/dev ({@code ON DELETE CASCADE}). On couvre le contrat HTTP
 * stable de l'incrément DELETE (204/404/403).
 */
@QuarkusTest
class ShowDateControllerDeleteTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    @Test
    @TestSecurity(user = "ctrl-delete-mgr", roles = {"MANAGER"})
    @DisplayName("DELETE /show-dates/{id} en MANAGER retourne 204 et supprime la date")
    void deleteById_whenRoleIsManagerAndShowDateExists_returns204() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-del-ok");
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(fx.managerFirebaseUid(), fx.managerFirebaseUid() + "@test.com", "Manager")));
        assertEquals(1, countShowDateById(fx.showDateId()));

        given()
                    .when().delete("/api/show-dates/" + fx.showDateId())
                    .then()
                    .statusCode(204);

        assertEquals(0, countShowDateById(fx.showDateId()));
    }

    @Test
    @TestSecurity(user = "ctrl-delete-mgr-404", roles = {"MANAGER"})
    @DisplayName("DELETE /show-dates/{id} en MANAGER retourne 404 si la date n'existe pas")
    void deleteById_whenRoleIsManagerAndShowDateMissing_returns404() {
        given()
                .when().delete("/api/show-dates/999999")
                .then()
                .statusCode(404)
                .body(equalTo("Date de spectacle introuvable."));
    }

    @Test
    @TestSecurity(user = "ctrl-delete-artist", roles = {"ARTIST"})
    @DisplayName("DELETE /show-dates/{id} en ARTIST retourne 403 et ne supprime pas la date")
    void deleteById_whenRoleIsArtist_returns403() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-del-forbidden");
        assertEquals(1, countShowDateById(fx.showDateId()));

        given()
                .when().delete("/api/show-dates/" + fx.showDateId())
                .then()
                .statusCode(403);

        assertEquals(1, countShowDateById(fx.showDateId()));
    }

    private ShowDateFixture persistShowDateFixture(String uidPrefix) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity manager = new VioletteUserEntity();
            manager.setFirebaseUid(uidPrefix + "-mgr");
            manager.setEmail(uidPrefix + "-mgr@test.com");
            manager.setFirstName("Manager");
            manager.setLastName("Delete");
            manager.setRoles(Set.of(UserRole.MANAGER));
            manager.setSkills(Set.of());
            violetteUserRepository.persist(manager);

            CabaretCompanyEntity company = new CabaretCompanyEntity();
            company.setName("Compagnie " + uidPrefix);
            company.setManager(manager);
            cabaretCompanyRepository.persist(company);

            ShowDateEntity showDate = new ShowDateEntity();
            showDate.setCompany(company);
            showDate.setEventDate(LocalDate.of(2026, 2, 15));
            showDate.setMeetingTime(LocalTime.of(19, 0));
            showDate.setLocation("Paris");
            showDate.setClientContactName("Contact Test");
            showDate.setClientContactPhone("0601020304");
            showDateRepository.persist(showDate);
            showDateRepository.flush();

            userTransaction.commit();
            return new ShowDateFixture(showDate.getId(), manager.getFirebaseUid());
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private long countShowDateById(Long showDateId) throws Exception {
        userTransaction.begin();
        try {
            long count = showDateRepository.count("id", showDateId);
            userTransaction.commit();
            return count;
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private record ShowDateFixture(Long showDateId, String managerFirebaseUid) {
    }
}
