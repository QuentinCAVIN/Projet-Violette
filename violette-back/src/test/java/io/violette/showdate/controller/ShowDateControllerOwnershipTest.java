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
import io.violette.showdate.repository.ShowDateSkillRequirementRepository;
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
import static org.hamcrest.Matchers.hasSize;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.when;

/**
 * Tests d'autorisation OWASP A01 (Broken Access Control) sur les endpoints de lecture et de mutation
 * de {@link ShowDateController} (et disponibilités manager via {@link ArtistAvailabilityService}).
 * Vérifie qu'un manager ne peut agir que sur les dates appartenant à SA compagnie.
 *
 * <p>Chaque test crée deux compagnies distinctes (A et B) avec leurs managers.
 * Le principal JWT est simulé via {@link InjectMock} sur {@link CurrentUserContextProvider}.
 */
@QuarkusTest
class ShowDateControllerOwnershipTest {

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Inject
    ShowDateRepository showDateRepository;

    @Inject
    ShowDateSkillRequirementRepository showDateSkillRequirementRepository;

    @Inject
    CabaretCompanyRepository cabaretCompanyRepository;

    @Inject
    VioletteUserRepository violetteUserRepository;

    @Inject
    UserTransaction userTransaction;

    // --- GET /api/show-dates/{id} ---

    @Test
    @TestSecurity(user = "ownership-get-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — manager de la compagnie A lit sa propre date → 200")
    void getById_whenManagerReadsOwnCompanyDate_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateAId)
                    .then()
                    .statusCode(200)
                    .body("id", equalTo(fx.showDateAId.intValue()));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-get-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — manager de la compagnie A lit une date de la compagnie B → 403")
    void getById_whenManagerReadsOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-get-404", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id} — date inexistante → 404 (avant la vérification d'ownership)")
    void getById_whenShowDateDoesNotExist_returns404() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-get-404");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/999999999")
                    .then()
                    .statusCode(404)
                    .body(equalTo("Date de spectacle introuvable."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- GET /api/show-dates/company/{companyId} ---

    @Test
    @TestSecurity(user = "ownership-list-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/company/{companyId} — manager A demande les dates de la compagnie A → 200")
    void getByCompanyId_whenManagerRequestsOwnCompany_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-list-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/company/" + fx.companyAId)
                    .then()
                    .statusCode(200);
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-list-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/company/{companyId} — manager A demande les dates de la compagnie B → 403")
    void getByCompanyId_whenManagerRequestsOtherCompany_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-list-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/company/" + fx.companyBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- DELETE /api/show-dates/{id} ---

    @Test
    @TestSecurity(user = "ownership-del-ok", roles = {"MANAGER"})
    @DisplayName("DELETE /show-dates/{id} — manager A supprime une date de sa compagnie → 204")
    void deleteById_whenManagerDeletesOwnCompanyDate_returns204() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-del-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().delete("/api/show-dates/" + fx.showDateAId)
                    .then()
                    .statusCode(204);

            assertEquals(0, countShowDateById(fx.showDateAId));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-del-403", roles = {"MANAGER"})
    @DisplayName("DELETE /show-dates/{id} — manager A supprime une date de la compagnie B → 403")
    void deleteById_whenManagerDeletesOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-del-403");
        mockManagerA(fx);

        try {
            given()
                    .when().delete("/api/show-dates/" + fx.showDateBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));

            assertEquals(1, countShowDateById(fx.showDateBId));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- PATCH /api/show-dates/{id} ---

    @Test
    @TestSecurity(user = "ownership-patch-ok", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} — manager A met à jour une date de sa compagnie → 200")
    void patchById_whenManagerUpdatesOwnCompanyDate_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-patch-ok");
        mockManagerA(fx);

        try {
            given()
                    .contentType("application/json")
                    .body("{\"location\":\"Lieu mis à jour A\"}")
                    .when().patch("/api/show-dates/" + fx.showDateAId)
                    .then()
                    .statusCode(200)
                    .body("location", equalTo("Lieu mis à jour A"));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-patch-403", roles = {"MANAGER"})
    @DisplayName("PATCH /show-dates/{id} — manager A met à jour une date de la compagnie B → 403")
    void patchById_whenManagerUpdatesOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-patch-403");
        mockManagerA(fx);

        try {
            given()
                    .contentType("application/json")
                    .body("{\"location\":\"Tentative interdite\"}")
                    .when().patch("/api/show-dates/" + fx.showDateBId)
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- POST /api/show-dates/{id}/skill-requirements ---

    @Test
    @TestSecurity(user = "ownership-skill-post-ok", roles = {"MANAGER"})
    @DisplayName("POST /show-dates/{id}/skill-requirements — manager A ajoute un besoin sur sa date → 201")
    void addSkillRequirement_whenManagerActsOnOwnCompanyDate_returns201() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-skill-post-ok");
        mockManagerA(fx);

        try {
            given()
                    .contentType("application/json")
                    .body("""
                            {
                              "skill": "DANCE",
                              "requiredCount": 2,
                              "netFee": 100.00
                            }
                            """)
                    .when().post("/api/show-dates/" + fx.showDateAId + "/skill-requirements")
                    .then()
                    .statusCode(201)
                    .body("skill", equalTo("DANCE"));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-skill-post-403", roles = {"MANAGER"})
    @DisplayName("POST /show-dates/{id}/skill-requirements — manager A ajoute un besoin sur la date B → 403")
    void addSkillRequirement_whenManagerActsOnOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-skill-post-403");
        mockManagerA(fx);

        try {
            given()
                    .contentType("application/json")
                    .body("""
                            {
                              "skill": "DANCE",
                              "requiredCount": 2,
                              "netFee": 100.00
                            }
                            """)
                    .when().post("/api/show-dates/" + fx.showDateBId + "/skill-requirements")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- GET /api/show-dates/{id}/skill-requirements ---

    @Test
    @TestSecurity(user = "ownership-skill-get-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id}/skill-requirements — manager A lit les besoins de sa date → 200")
    void getSkillRequirements_whenManagerReadsOwnCompanyDate_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-skill-get-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateAId + "/skill-requirements")
                    .then()
                    .statusCode(200)
                    .body("$", hasSize(0));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-skill-get-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id}/skill-requirements — manager A lit les besoins de la date B → 403")
    void getSkillRequirements_whenManagerReadsOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-skill-get-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateBId + "/skill-requirements")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- GET /api/show-dates/{id}/availabilities ---

    @Test
    @TestSecurity(user = "ownership-avail-get-ok", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id}/availabilities — manager A lit les disponibilités de sa date → 200")
    void getAvailabilities_whenManagerReadsOwnCompanyDate_returns200() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-avail-get-ok");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateAId + "/availabilities")
                    .then()
                    .statusCode(200)
                    .body("$", hasSize(0));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    @Test
    @TestSecurity(user = "ownership-avail-get-403", roles = {"MANAGER"})
    @DisplayName("GET /show-dates/{id}/availabilities — manager A lit les disponibilités de la date B → 403")
    void getAvailabilities_whenManagerReadsOtherCompanyDate_returns403() throws Exception {
        OwnershipFixture fx = persistOwnershipFixture("own-avail-get-403");
        mockManagerA(fx);

        try {
            given()
                    .when().get("/api/show-dates/" + fx.showDateBId + "/availabilities")
                    .then()
                    .statusCode(403)
                    .body(equalTo("Accès refusé."));
        } finally {
            deleteOwnershipFixture(fx);
        }
    }

    // --- Fixtures ---

    private void mockManagerA(OwnershipFixture fx) {
        when(currentUserContextProvider.getCurrentPrincipal())
                .thenReturn(Optional.of(new JwtPrincipalInfo(
                        fx.managerAFirebaseUid,
                        fx.managerAFirebaseUid + "@test.com",
                        "Manager A"
                )));
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

    private record OwnershipFixture(
            Long managerAId,
            String managerAFirebaseUid,
            Long companyAId,
            Long showDateAId,
            Long managerBId,
            Long companyBId,
            Long showDateBId
    ) {
    }

    private OwnershipFixture persistOwnershipFixture(String seed) throws Exception {
        userTransaction.begin();
        try {
            VioletteUserEntity managerA = buildManager(seed + "-mgr-a");
            VioletteUserEntity managerB = buildManager(seed + "-mgr-b");
            violetteUserRepository.persist(managerA);
            violetteUserRepository.persist(managerB);

            CabaretCompanyEntity companyA = buildCompany("Compagnie A " + seed, managerA);
            CabaretCompanyEntity companyB = buildCompany("Compagnie B " + seed, managerB);
            cabaretCompanyRepository.persist(companyA);
            cabaretCompanyRepository.persist(companyB);

            ShowDateEntity showDateA = buildShowDate(companyA, LocalDate.of(2026, 10, 1), seed + " A");
            ShowDateEntity showDateB = buildShowDate(companyB, LocalDate.of(2026, 10, 2), seed + " B");
            showDateRepository.persist(showDateA);
            showDateRepository.persist(showDateB);
            showDateRepository.flush();

            userTransaction.commit();
            return new OwnershipFixture(
                    managerA.getId(),
                    managerA.getFirebaseUid(),
                    companyA.getId(),
                    showDateA.getId(),
                    managerB.getId(),
                    companyB.getId(),
                    showDateB.getId()
            );
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private void deleteOwnershipFixture(OwnershipFixture fx) throws Exception {
        userTransaction.begin();
        try {
            showDateSkillRequirementRepository.findByShowDateId(fx.showDateAId).forEach(showDateSkillRequirementRepository::delete);
            showDateSkillRequirementRepository.findByShowDateId(fx.showDateBId).forEach(showDateSkillRequirementRepository::delete);
            showDateRepository.findByIdOptional(fx.showDateAId).ifPresent(showDateRepository::delete);
            showDateRepository.findByIdOptional(fx.showDateBId).ifPresent(showDateRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyAId).ifPresent(cabaretCompanyRepository::delete);
            cabaretCompanyRepository.findByIdOptional(fx.companyBId).ifPresent(cabaretCompanyRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerAId).ifPresent(violetteUserRepository::delete);
            violetteUserRepository.findByIdOptional(fx.managerBId).ifPresent(violetteUserRepository::delete);
            userTransaction.commit();
        } catch (Exception e) {
            userTransaction.rollback();
            throw e;
        }
    }

    private VioletteUserEntity buildManager(String firebaseUid) {
        VioletteUserEntity manager = new VioletteUserEntity();
        manager.setFirebaseUid(firebaseUid);
        manager.setEmail(firebaseUid + "@test.com");
        manager.setFirstName("Manager");
        manager.setLastName("Test");
        manager.setRoles(Set.of(UserRole.MANAGER));
        manager.setSkills(Set.of());
        return manager;
    }

    private CabaretCompanyEntity buildCompany(String name, VioletteUserEntity manager) {
        CabaretCompanyEntity company = new CabaretCompanyEntity();
        company.setName(name);
        company.setManager(manager);
        return company;
    }

    private ShowDateEntity buildShowDate(CabaretCompanyEntity company, LocalDate eventDate, String location) {
        ShowDateEntity showDate = new ShowDateEntity();
        showDate.setCompany(company);
        showDate.setEventDate(eventDate);
        showDate.setMeetingTime(LocalTime.of(20, 0));
        showDate.setLocation("Lieu " + location);
        showDate.setClientContactName("Contact Test");
        showDate.setClientContactPhone("0600000000");
        showDate.setStatus(ShowDateStatus.INQUIRY);
        return showDate;
    }
}
