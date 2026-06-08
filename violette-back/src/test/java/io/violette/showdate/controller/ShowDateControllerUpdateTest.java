package io.violette.showdate.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.cabaretcompany.model.CabaretCompanyEntity;
import io.violette.cabaretcompany.repository.CabaretCompanyRepository;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import io.violette.showdate.model.ShowDateEntity;
import io.violette.showdate.model.ShowDateStatus;
import io.violette.showdate.repository.ShowDateRepository;
import io.violette.violetteuser.model.UserRole;
import io.violette.violetteuser.model.VioletteUserEntity;
import io.violette.violetteuser.repository.VioletteUserRepository;
import jakarta.inject.Inject;
import jakarta.transaction.UserTransaction;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.Set;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

@QuarkusTest
class ShowDateControllerUpdateTest {

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
    @TestSecurity(user = "ctrl-update-mgr", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} en MANAGER met à jour les champs fournis et retourne 200")
    void patchById_whenRoleIsManagerAndShowDateExists_returns200AndUpdatesFields() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-upd-ok");
        mockManagerPrincipal(fx);

        given()
                .contentType("application/json")
                .body("""
                        {
                          "eventDate": "2026-06-02",
                          "location": "Paris 10e",
                          "showDetails": "Mise à jour test"
                        }
                        """)
                .when().patch("/api/show-dates/" + fx.showDateId())
                .then()
                .statusCode(200)
                .body("id", equalTo(fx.showDateId().intValue()))
                .body("eventDate", equalTo("2026-06-02"))
                .body("location", equalTo("Paris 10e"))
                .body("showDetails", equalTo("Mise à jour test"))
                .body("clientContactName", equalTo("Contact Initial"));

        userTransaction.begin();
        try {
            ShowDateEntity entity = showDateRepository.findByIdOptional(fx.showDateId()).orElseThrow();
            assertEquals(LocalDate.of(2026, 6, 2), entity.getEventDate());
            assertEquals(LocalTime.of(19, 0), entity.getMeetingTime());
            assertEquals("Paris 10e", entity.getLocation());
            assertEquals("Contact Initial", entity.getClientContactName());
            assertEquals("0601020304", entity.getClientContactPhone());
            assertEquals("Mise à jour test", entity.getShowDetails());
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    @Test
    @TestSecurity(user = "ctrl-update-mgr-404", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} en MANAGER retourne 404 si la date n'existe pas")
    void patchById_whenRoleIsManagerAndShowDateMissing_returns404() {
        given()
                .contentType("application/json")
                .body("{\"location\":\"Paris\"}")
                .when().patch("/api/show-dates/999999")
                .then()
                .statusCode(404)
                .body(equalTo("Date de spectacle introuvable."));
    }

    @Test
    @TestSecurity(user = "ctrl-update-status-mgr", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} en MANAGER peut passer INQUIRY -> OPTION")
    void patchById_whenManagerUpdatesStatusToOption_returns200AndPersistsStatus() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-upd-status");
        mockManagerPrincipal(fx);

        given()
                .contentType("application/json")
                .body("""
                        {
                          "status": "OPTION"
                        }
                        """)
                .when().patch("/api/show-dates/" + fx.showDateId())
                .then()
                .statusCode(200)
                .body("status", equalTo("OPTION"));

        userTransaction.begin();
        try {
            ShowDateEntity entity = showDateRepository.findByIdOptional(fx.showDateId()).orElseThrow();
            assertEquals(ShowDateStatus.OPTION, entity.getStatus());
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    @Test
    @TestSecurity(user = "ctrl-update-status-bad", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} en MANAGER refuse INQUIRY -> CONFIRMED en v0.4.0 (400)")
    void patchById_whenManagerUsesInvalidStatusTransition_returns400() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-upd-status-bad");
        mockManagerPrincipal(fx);

        given()
                .contentType("application/json")
                .body("""
                        {
                          "status": "CONFIRMED"
                        }
                        """)
                .when().patch("/api/show-dates/" + fx.showDateId())
                .then()
                .statusCode(400);
    }

    @Test
    @TestSecurity(user = "ctrl-update-artist", roles = {"ARTIST"})
    @DisplayName("PATCH /show-dates/{id} en ARTIST retourne 403 et ne modifie pas la date")
    void patchById_whenRoleIsArtist_returns403AndDoesNotUpdate() throws Exception {
        ShowDateFixture fx = persistShowDateFixture("ctrl-upd-forbidden");

        given()
                .contentType("application/json")
                .body("{\"location\":\"Interdit\"}")
                .when().patch("/api/show-dates/" + fx.showDateId())
                .then()
                .statusCode(403);

        userTransaction.begin();
        try {
            ShowDateEntity entity = showDateRepository.findByIdOptional(fx.showDateId()).orElseThrow();
            assertEquals("Paris", entity.getLocation());
            assertEquals(ShowDateStatus.INQUIRY, entity.getStatus());
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private ShowDateFixture persistShowDateFixture(String uidPrefix) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity manager = new VioletteUserEntity();
            manager.setFirebaseUid(uidPrefix + "-mgr");
            manager.setEmail(uidPrefix + "-mgr@test.com");
            manager.setFirstName("Manager");
            manager.setLastName("Update");
            manager.setRoles(Set.of(UserRole.MANAGER));
            manager.setSkills(Set.of());
            violetteUserRepository.persist(manager);

            CabaretCompanyEntity company = new CabaretCompanyEntity();
            company.setName("Compagnie " + uidPrefix);
            company.setManager(manager);
            cabaretCompanyRepository.persist(company);

            ShowDateEntity showDate = new ShowDateEntity();
            showDate.setCompany(company);
            showDate.setEventDate(LocalDate.of(2026, 6, 1));
            showDate.setMeetingTime(LocalTime.of(19, 0));
            showDate.setLocation("Paris");
            showDate.setClientContactName("Contact Initial");
            showDate.setClientContactPhone("0601020304");
            showDate.setShowDetails("Détails initiaux");
            showDateRepository.persist(showDate);
            showDateRepository.flush();

            userTransaction.commit();
            return new ShowDateFixture(showDate.getId(), manager.getFirebaseUid());
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void mockManagerPrincipal(ShowDateFixture fx) {
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(
                        fx.managerFirebaseUid(),
                        fx.managerFirebaseUid() + "@test.com",
                        "Manager"
                )));
    }

    private record ShowDateFixture(Long showDateId, String managerFirebaseUid) {
    }
}

